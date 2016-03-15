# Active Record Lite

An ORM inspired by the basic functionality of Active Record.

# Outline

This project uses metaprogramming to imitate some of the functionality of Active Record Lite.  Model's inheriting from SQLObject will be able to have `has_many` `belongs_to` and `has_one_through` relations that can be defined.  Instances of models can also be searched for using `where`.

# Instructions

* Clone this repo, run bundle install
* Build your table in a .sql file and save in root directory.
* Insert your database and sql file info as instructed in lib/db_info.rb
* Models should inherit from SQLObject

# `DBConnection` & `DBInfo`

`DBConnection` and `DBInfo` are used to access the database itself.  The Database and SQL files should be saved to the top level and included in `DBInfo` as demonstrated with the example database. `DBConnection` will then be able to access the database.

# `SQLObject`

Model classes should inherit from `SQLObject`.  `SQLObject` is extended by the `associatable` and `searchable` modules.  This allows any model inheriting from `SQLObject` to gain the following methods:
* `#table_name` returns the table name
* `#table_name=` sets the table name
* `#columns` returns that models columns in the database
* `#attributes` returns attributes of the model
* `#insert` inserts a new object into the database
* `#save` inserts or updates an object into the database

# `Associatable`

Associations between models can be defined using `BelongsToOptions` and `HasManyOptions`.  For example, to define a `has_many` relationship where a model `Manager` has many `Players`:

````
class Player < SQLObject
  belongs_to :manager, foreign_key: :manager_id

  finalize!
end

class Manager < SQLObject
  self.table_name = 'managers'

  has_many :players, foreign_key: :manager_id
  belongs_to :team

  finalize!
end
````

A `Player` object will now respond to a call of `player.manager` with the proper object that has been defined.  `manager.players` will also respond with the objects that have been defined to `belong_to` it.

# `Searchable`

The database may be searched using the `where` command called upon the model class.  For example:

````
Manager.where(id: 1)
````

will return the manager with the id 1.  This will work using all columns defined for a model in the database.
