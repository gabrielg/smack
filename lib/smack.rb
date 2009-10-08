module Smack
  def self.up; Object.instance_eval { include Smack }; end
  def smack_inject(substitutions)
    (class << self; self; end).instance_eval { @smack_subs = (@smack_subs || {}).merge!(substitutions) }
  end
  def smack_score(klass_or_mod)
    [self, *(class << self; self; end).ancestors].any? { |mod| (found_mod = mod.smack_fetch(klass_or_mod)) ? (break(found_mod)) : nil } || klass_or_mod
  end
  def smack_fetch(klass_or_mod)
    (class << self; self; end).instance_eval { @smack_subs ? @smack_subs[klass_or_mod] : nil }
  end
end # Smack