require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info('#{table_name}')"
        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.each do |column|
            column_names << column["name"]
        end
        column_names.compact
    end

    def initialize(attributes = {})
        attributes.each do |k, v|
            self.send("#{k}=", v)
        end
    end

    def table_name_for_insert
        self.class.to_s.downcase.pluralize
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|column_name| column_name == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |column_name|
            values << "'#{self.send(column_name)}'" unless send(column_name).nil?
        end
        values.join(", ")
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
    end

    def  self.find_by(attribute)
        column = attribute.keys[0].to_s
        value = attribute.values[0]
        DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{column} = ?", value)
    end



end