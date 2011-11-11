ID_COLUMN = 'INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)'
INT_UNSIGNED = 'INT UNSIGNED DEFAULT 0'
LINKED_ID_COLUMN = 'INT UNSIGNED NOT NULL'
LINKED_ID_COLUMN_BIGINT = 'BIGINT UNSIGNED NOT NULL'

module CustomColumnTypes
    def double(*args)
        args.last[:limit] = 53 if args.last.is_a? Hash
        float *args
    end 
end 

module ActiveRecord
    module ConnectionAdapters
        class Table
            include CustomColumnTypes
        end 
        class TableDefinition
            include CustomColumnTypes
        end 
    end 
end