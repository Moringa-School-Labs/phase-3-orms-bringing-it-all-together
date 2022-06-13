class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end


    # Create table
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    # Drop table
    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    # Save or insert a new record into the db and return the instance
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)

        #returns an instance of the dog class
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    # Create a new row in the db
    # Return a new instance of the dog class

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed) #creating a new dog
        dog.save #persist data to the db
    end


    # Reading data from db
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    # Select all from db
    def self.all
        sql = <<-SQL
        SELECT * 
        FROM dogs
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end


    # Find new dog object by name
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    # Find new dog by id
   def self.find(id)
     sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE id = ?
     LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
    end.first
   end



end
