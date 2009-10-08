require 'test_helper'
Smack.init

class Useless
  def write_a_song
    smack_get(Junkie).new.write_a_song
  end
end

class Junkie
  
  def write_a_song
    "i'm a regular junkie, not a talented one"
  end
  
end

class LayneStaley < Junkie
  
  def write_a_song
    "THEM BONES"
  end
  
end

class SidVicious < Junkie
  
  def write_a_song
    "i'm a terrible bass player, i can't write songs"
  end
  
end

class AlJourgensen < Junkie
  
  def write_a_song
    "i'm a burnout who writes terrible thrash metal now"
  end
  
end

class Band
end

class AliceInChains < Band
end

module BandManager
  smack_inject Junkie => LayneStaley

  def get_a_song
    smack_get(Junkie).new.write_a_song
  end
  
end

module RecordCompany
  include BandManager
  smack_inject Junkie => SidVicious
end

module CreativeConglomerate
  include RecordCompany
  smack_inject Band => AliceInChains
  
  def get_a_band
    smack_get(Band).new
  end
  
  def sell_a_song
    "BUY BUY BUY " + smack_get(Junkie).new.write_a_song
  end
end

class Interscope
  include RecordCompany
end

class InterscopeSubsidiary < Interscope
end

class AnotherInterscopeSubsidiary < Interscope
  smack_inject Junkie => LayneStaley
end

context "Smack" do
  
  context "a module with a Smack substition" do
    setup do
      Object.new.extend(BandManager)
    end
    
    should "use the substituted in class" do
      topic.get_a_song
    end.equals("THEM BONES")
  end # a module with a Smack substition
  
  context "a module including another module with a Smack substitution and overriding it" do
    setup do
      Object.new.extend(RecordCompany)
    end
    
    should "use the override" do
      topic.get_a_song
    end.equals("i'm a terrible bass player, i can't write songs")
    
    should "not stomp on the included module's substitutions" do
      Object.new.extend(BandManager).get_a_song
    end.equals("THEM BONES") 
  end # a module including another module with a Smack substitution and overriding it
  
  context "an instance of an object with its own Smack injections" do
   
    setup do
      obj = Object.new.extend(BandManager)
      obj.smack_inject(Junkie => AlJourgensen)
      obj
    end
    
    should "use the subbed in Smack injection for that instance" do
      topic.get_a_song
    end.equals("i'm a burnout who writes terrible thrash metal now")
   
    should "not stomp on the original substitution" do
      Object.new.extend(BandManager).get_a_song
    end.equals("THEM BONES")
    
  end # an instance of an object with its own Smack injections
  
  context "a class including a module with a Smack injection" do
    setup do
      Interscope.new
    end
    
    should "use the smack injection of the module" do
      topic.get_a_song
    end.equals("i'm a terrible bass player, i can't write songs")
  end # a class including a module with a Smack injection
  
  context "a class extending a class that includes a module with a Smack injection" do
    setup do
      InterscopeSubsidiary.new
    end
    
    should "use the smack injection of the parent class" do
      topic.get_a_song
    end.equals("i'm a terrible bass player, i can't write songs")
  end # a class extending a class that includes a module with a Smack injection
  
  context "a class extending a class that includes a module with a Smack injection and providing its own injection" do
    setup do
      AnotherInterscopeSubsidiary.new
    end
    
    should "use its own injection" do
      topic.get_a_song
    end.equals("THEM BONES")
    
    should "not stomp on other injections" do
      InterscopeSubsidiary.new.get_a_song
    end.equals("i'm a terrible bass player, i can't write songs")
  end # a class extending a class that includes a module with a Smack injection and providing its own injection
  
  context "a module including another module and providing extra substitutions" do
    setup do
      Object.new.extend(CreativeConglomerate)
    end
    
    should "use the given substitution" do
      topic.get_a_band.class == AliceInChains
    end
    
    should "use inherited substitutions" do
      topic.sell_a_song
    end.equals("BUY BUY BUY i'm a terrible bass player, i can't write songs")

  end # a module including another module and providing extra substitutions
  
  context "a class with no substitutions" do
    setup do
      Useless.new
    end
      
    should "just return the value given to smack_get" do
      topic.write_a_song
    end.equals("i'm a regular junkie, not a talented one")
  end # a class with no substitutions
end