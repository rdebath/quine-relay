require "yaml"
require_relative "code-gen"

apts = RunSteps.flat_map {|s| s.apt }
other_packages = %w(cmake libpng12-dev libgd2-xpm-dev groff tcc)


apts = apts.flatten.map {|apt| apt }.compact
apts.delete("ruby2.1")

yaml = {}
yaml["sudo"] = "required"
yaml["services"] = ["docker"]
yaml["language"] = "ruby"
yaml["rvm"] = ["2.2.0"]
yaml["env"] = ["PATH=/usr/games:$PATH"]
yaml["before_install"] = [
  "sudo apt-get update",
  'sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade',
]
apts = [*apts.flatten.compact.uniq, *other_packages].sort
apt_width = apts.map {|apt| apt.size }.max
apts.each_with_index do |apt, i|
  yaml["before_install"] << "travis_retry sudo apt-get install #{ apt }#{ " " * (apt_width - apt.size) } # #{ "%#{ apts.size.to_s.size }d" % (i + 1) } / #{ apts.size }"
end
yaml["before_script"] = [
  "make -C vendor/",
]
yaml["script"] = ["make CC=tcc"]


File.write("../.travis.yml", YAML.dump(yaml))
