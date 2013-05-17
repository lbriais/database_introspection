# DatabaseIntrospection

This gem does a bit the reverse action of what you do with Rails generator.

It introspects the database and creates __dynamically__ ActiveRecord descendants that can be used by your application, including some Rails associations helper methods.

It is intended to be primarily used within rails applications but nothing prevents you to use standalone, provided the fact you are already connected to a database.


## Installation

Add this line to your application's Gemfile:

    gem 'database_introspection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install database_introspection

## Usage

### Basic database introspection

To introspect the database, you just have to call the following method:

```ruby
DynamicModel.introspect_database
```

By default it will analyse all database tables starting by "user_defined_", and will create ActiveRecord::Base descendant to handle them.

For example if your database contains the following tables:

```
user_defined_table1
user_defined_table2
user_defined_table3
user_defined_table4
```
The call to `DynamicModel.introspect_database`, will inject the following classes in your application:

```ruby
DynamicModel::ManagedDomains::UserDefined::Table1
DynamicModel::ManagedDomains::UserDefined::Table2
DynamicModel::ManagedDomains::UserDefined::Table3
DynamicModel::ManagedDomains::UserDefined::Table4
```

### Architecture

#### Classes and modules generated

* `DynamicModel` is the module that contains methods to introspect the database.
* `DynamicModel::ManagedDomain` contains some methods to manipulates the domains introspected.
* Then for example in the first example, `DynamicModel::ManagedDomains::UserDefined` is a module created dynamically from the domain name (ie tables prefix). It contains itself some methods to easily manipulate the tables or generated classes.
* The `DynamicModel::ManagedDomains::UserDefined::Tablex` classes are descendants of ActiveRecord::Base that you will use in your application.

Of course if you provide another domain name (ie tables prefix) the corresponding modules and classes will be created accordingly. Running:

```ruby
DynamicModel.introspect_database :another_domain
```

On a database containing the following tables:

```
another_domain_table1
another_domain_table2
```

Will inject the following classes in your application:

```ruby
DynamicModel::ManagedDomains::AnotherDomain::Table1
DynamicModel::ManagedDomains::AnotherDomain::Table2
```
and of course the following module:
```ruby
DynamicModel::ManagedDomains::AnotherDomain
```

#### Generated classes

The classes generated will actually have some behaviour added by extending the module `DynamicModel::ActiveRecordExtension` to basically be aware of the domain they belong to.

### Database relationships

Provided you follow the standard rails rules for ids, for example:

if `user_defined_table1` contains `user_defined_table2_id` (not yet implemented) or `table2_id`, the introspector will understand there is a relationship between the tables and create the ActiveRecord associations accordingly adding all the standard helper methods to the generated classes !

## To do

* Improve Readme
* Added inline code documentation
* Improve table relationship introspection

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
