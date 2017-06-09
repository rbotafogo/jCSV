hash = {}

key = "placebo.john.1"
key.split('.').reduce(hash) { |h,m| h[m] ||= {} }

*key, last = key.split(".")
key.inject(hash, :fetch)[last] = {a: 1, b:2, c: 3}

key = "placebo.john.2"
key.split('.').reduce(hash) { |h,m| h[m] ||= {} }

*key, last = key.split(".")
key.inject(hash, :fetch)[last] = {a: 10, b:20, c: 30}

puts hash #=> {"one"=>{"two"=>{"three"=>{}}}}
p hash["placebo"]["john"]["2"]

=begin

require 'hashie'

cl = Hashie::Clash.new

cl.placebo!.john!.p1(a: 1, b: 2, c: 3)
#cl.placebo!.john!.p2(a: 10, b: 20, c: 30)

p cl

=end



rh = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }

h = Hash.new

=begin
h["placebo"] ||= Hash.new
h["med"] ||= Hash.new
h["placebo"]["john"] ||= Hash.new
h["placebo"]["john"][1] ||= Hash.new

h["placebo"] ||= Hash.new
h["placebo"]["john"] ||= Hash.new
h["placebo"]["john"][2] ||= Hash.new

h["placebo"]["john"][1] = {a: 1, b: 2, c: 3}
h["placebo"]["john"][2] = {a: 2, b: 10, c: 50}

p h["placebo"]
=end

=begin
h["placebo"] ||= Hash.new
h["placebo"]["john"] ||= Hash.new
h["placebo"]["john"]["1"] ||= Hash.new

key = "placebo.john.1"

*key, last = key.split(".")
key.inject(h, :fetch)[last] = {a: 1, b:2, c: 3}

h["placebo"] ||= Hash.new
h["placebo"]["john"] ||= Hash.new
h["placebo"]["john"]["2"] ||= Hash.new

key = "placebo.john.2"

*key, last = key.split(".")
key.inject(h, :fetch)[last] = {a: 10, b:20, c: 30}

p h["placebo"]["john"]["2"]
=end
