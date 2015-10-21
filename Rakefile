require 'rake'
require 'fileutils'
require 'plist'

task :updatepluginuuid do
  plistfile = 'GMailinator/Info.plist'

  doc = Plist::parse_xml(plistfile)
  uuids = doc["SupportedPluginCompatibilityUUIDs"]
  Dir["/Applications/Xcode*.app"].each do |obj|
    plugin_uuid = `defaults read /Applications/Mail.app/Contents/Info PluginCompatibilityUUID`
    plugin_uuid.chomp!
    if ! uuids.include?(plugin_uuid)
      uuids.push(plugin_uuid)
    end
  end
  File.write(plistfile, doc.to_plist)
end

task :default => [:xcode56]
