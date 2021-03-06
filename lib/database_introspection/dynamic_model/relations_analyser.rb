# -*- coding: utf-8 -*-

# This class is in charge to analyse the relationships between the tables of the domain.
# It will then add association methods to the classes.
class DynamicModel::RelationsAnalyser
  KEY_IDENTIFIER = /_id$/

  # 
  attr_reader :alterations

  def initialize(klasses)
    @klasses = klasses
    @alterations = {}
  end

  def run
    raise "cannot rerun analysis with the same object... Create a new instance !" if @did_run
    return if @klasses.empty?
    @domain = @klasses[0].domain
    introspect_belongs_to
    verify_if_has_many_relations_could_be_actually_has_one
    discover_has_many_through_from_belongs_to
    apply_alterations
    @did_run = true
  end


  private

  def discover_has_many_through_from_belongs_to
    puts "Has_many_through analysis started."
    @alterations.each do |model, alterations|
      alterations[:has_many_though] ||= []
      alterations.each do |association_type, associations|
        next unless association_type == :belongs_to
        # If there is only one belongs_to, there cannot be a has_many_through
        next if associations.size < 2
        analyses_has_many_through_association model, associations
      end
    end
  ensure
    puts "Has_many_though analysis completed."
  end

  def introspect_belongs_to
    puts "Belongs_to analysis started."
    # scoped_table_names_hash is a hash with keys made of table names (both scoped and unscoped)
    # and the values are the associated classes.
    scoped_table_names_hash = Hash[@domain.scoped_table_names.zip @domain.model_classes]
    scoped_table_names_hash.merge! Hash[@domain.table_names.zip @domain.model_classes]
    @klasses.each do |klass|
      @alterations[klass] ||= {}
      # Find attributes ending by "_id"
      klass.attribute_names.grep(KEY_IDENTIFIER) do |attr_name|
        if klass.columns_hash[attr_name].type == :integer
          # Check if there is a table in the domain that may be linked to this field
          candidate_table_name = attr_name.gsub(KEY_IDENTIFIER, '').pluralize
          candidate_target_class = scoped_table_names_hash[candidate_table_name]
          # Creates a belongs_to relation
          if scoped_table_names_hash.keys.include? candidate_table_name
            @alterations[klass][:belongs_to] ||= []
            @alterations[klass][:belongs_to] << {
                key: attr_name,
                class: candidate_target_class
            }
            # and the reverse, by default has_many
            @alterations[candidate_target_class] ||= {}
            @alterations[candidate_target_class][:has_many] ||= []
            @alterations[candidate_target_class][:has_many] << {
                class: klass
            }
          end
        end
      end
    end
  ensure
    puts "Belongs_to analysis completed."
  end


  def verify_if_has_many_relations_could_be_actually_has_one
    puts "Has_many analysis started."
    @alterations.each do |model, alterations|
      alterations[:has_one] ||= []
      alterations.each do |association_type, associations|
        next unless association_type == :has_many
        associations.map! do |description|
          if analyses_has_many_association model, description
            # This is actually a has_one
            alterations[:has_one] << description
            nil
          else
            description
          end
        end
        associations.compact!
      end
    end
  ensure
    puts "Has_many analysis completed."
  end

  def analyses_has_many_through_association(model, associations)
    # As there are multiple belongs_to in this class, all combinations
    # should lead to a has_many :through
    # Wow, Ruby rocks !!
    associations.combination(2).each do |left, right|
      @alterations[left[:class]][:has_many_through] ||= []
      @alterations[right[:class]][:has_many_through] ||= []


      @alterations[left[:class]][:has_many_through] << {
        self_key: left[:key],
        key: right[:key],
        middle_class: model,
        class: right[:class]
      }
       @alterations[right[:class]][:has_many_through] << {
        self_key: right[:key],
        key: left[:key],
        middle_class: model,
        class: left[:class]
      }
    end
  end

  def analyses_has_many_association(model, description)
    # If one day I figure out how to determine if a has_many relation could be a has_one,
    # should be implemented here... Doesn't look like solvable...
    false
  end


  def apply_alterations
    @alterations.each do |model, alterations|
      puts "Processing alterations for #{model.list_name}"
      alterations.each do |association_type, associations|
        associations.each do |description|
          method_name = "add_#{association_type}_behaviour"
          self.send method_name, model, description
        end
      end
    end
  end


  def add_belongs_to_behaviour(model, description)
    field_name = description[:class].list_name.singularize.to_sym
    options = {foreign_key: description[:key], class_name: description[:class].name}
    model.belongs_to field_name, options
    puts " - belongs_to :#{field_name}, #{options.inspect}"
  end

  def add_has_many_behaviour(model, description)
    field_name = description[:class].list_name.to_sym
    options = {class_name: description[:class].name}
    model.has_many field_name, options
    # Attribute for mass assignment
    attr = field_name.to_s.singularize + "_ids"
    model.attr_accessible *(model.attr_accessible[:default].to_a << attr)
    puts " - has_many :#{field_name}, #{options.inspect}"
  end

  # TODO: maybe check the intermediate class and depending upon the fact it contains a primary key, if only 2 fields
  #       exist. It may be a habtm instead of has_many :through...
  def add_has_many_through_behaviour(model, description)
    field_name = description[:class].list_name.to_sym
    options = {through: description[:middle_class].list_name.to_sym, source: description[:class].list_name.singularize}
    model.has_many field_name, options
    # Attribute for mass assignment
    attr = field_name.to_s.singularize + "_ids"
    model.attr_accessible *(model.attr_accessible[:default].to_a << attr)
    puts " - has_many :#{field_name}, #{options.inspect}"
  end

  def add_has_one_behaviour(model, description)
    field_name = description[:class].list_name.singularize.to_sym
    options = {class_name: description[:class].name}
    model.has_one field_name, options
    puts " - has_one :#{field_name}, #{options.inspect}"
  end

end
