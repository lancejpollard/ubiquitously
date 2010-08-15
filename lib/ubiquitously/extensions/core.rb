# thanks to the answer here:
# http://stackoverflow.com/questions/3488203/how-do-i-see-where-in-the-class-hierarchy-a-method-was-defined-and-overridden-in
class Object
  def self.overridden_methods(parent_class = Object, within_tree = true)
    if within_tree
      defined_methods = ancestors[0..ancestors.index(parent_class) - 1].map { |object| object.instance_methods(false) }.flatten.uniq
      parent_methods = superclass.instance_methods
    else
      defined_methods = instance_methods(false)
      parent_methods = parent_class.instance_methods
    end
    defined_methods & parent_methods
  end
  
  def overridden_methods(parent_class = Object, within_tree = true)
    self.class.overridden_methods(parent_class, within_tree)
  end
  
  def self.overrides?(method, parent_class = Object, within_tree = true)
    overridden_methods(parent_class, within_tree).include?(method.to_s)
  end
  
  def overrides?(method, parent_class = Object, within_tree = true)
    self.class.overrides?(method, parent_class, within_tree)
  end
end

class Hash
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end
  
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
  
  # Destructively convert all keys to symbols.
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end
end

class Array
  def chop(separator = "", max = 40, &block)
    return self if self.join(separator).length < max # opt.
    result = []
    self.each do |word|
      break if (result.join(separator).length + word.length > max)
      word = yield word if block_given?
      result << word
      result
    end
    result
  end
  
  # separator = ", ",
  # max = 10_000
  # quote = true|false
  def taggify(space = " ", separator = ", ", max = 10_000)
    quoted = !(separator =~ /\s+/).nil?
    chop(separator, max) do |word|
      result = word.downcase.strip.gsub(/[^a-z0-9\.]/, space).squeeze(space)
      result = "\"#{result}\"" if quoted && !(result =~ /\s+/).nil?
      result
    end.join(separator)
  end
  
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end
end