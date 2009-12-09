module Shorty 
  def self.included(base)  
    base.send :extend, ClassMethods 
  end
  
  module ClassMethods 
    def acts_as_shorty(options = {})
      before_validation :validate_long_words

      write_inheritable_attribute(:shorty_options, {
                                    :except => (options[:except] || []),
				    :max => (options[:max] || 25)
                                  })
      
      class_inheritable_reader :shorty_options

      include Shorty::InstanceMethods
    end
  end  

  module InstanceMethods
    def validate_long_words
	errors.clear
      self.class.columns.each do |column|
        next unless (column.type == :string || column.type == :text)
        
        field = column.name.to_sym
        value = self[field]
        next if value.nil? || !value.is_a?(String)
	if shorty_options[:except].include?(field)
          next
	else
          errors.add(field,"entry is too long, max #{shorty_options[:max]} characters") if value && value.split(' ').find {|x| x.length > shorty_options[:max]}
        end
      end
      return !(errors.size > 0)
    end  
  end 
end 
ActiveRecord::Base.send :include, Shorty
