module LocalizedDate
  # Extensions to ActiveRecord::Base
  module ActiveRecord
    def self.included ( base )
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      
      def localized_text_dates(*field_names)
        field_names.each do |field_name|
          define_method "#{field_name}_l".to_sym do       
            invalid_value = self.instance_variable_get(:'@attributes')["#{field_name}_l"]
            value = self.send(field_name)
            if !invalid_value.nil?
               invalid_value
            else
              I18n.localize(value, :format => :short) unless value.nil?
            end
          end

          define_method "#{field_name}_l=".to_sym do |value|
            begin
              self.send("#{field_name}=".to_sym, Date.strptime(value, '%d.%m.%Y')) 
            rescue 
              self.instance_variable_get(:'@attributes')["#{field_name}_l"] = value
            end
          end

        end
      end

      def validates_localized_text_dates(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        validates_each attr_names, configuration do |record, attr_name, value|
          if !record.instance_variable_get(:'@attributes')["#{attr_name}"].blank?
            record.errors.add(attr_name, :inclusion, :default => I18n.t(:'activerecord.errors.messages.localized_date_format'), :value => value)
          end
        end
      end
      
       
    end  
  end  
end

ActiveRecord::Base.send(:include, LocalizedDate::ActiveRecord)