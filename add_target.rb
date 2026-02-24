require 'xcodeproj'

project_path = 'Menu.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Create MenuServer target
server_target = project.new_target(:application, 'MenuServer', :ios, '17.0')

# Add MenuServer folder
server_group = project.main_group.new_group('MenuServer', 'MenuServer')

# Configure build settings
server_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.youus.MenuServer'
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Menu Server'
  config.build_settings['DEVELOPMENT_TEAM'] = 'T6DP4Z2623'
  config.build_settings['INFOPLIST_KEY_NSLocalNetworkUsageDescription'] = 'MenuServer needs local network access to receive orders'
  config.build_settings['INFOPLIST_KEY_NSBonjourServices'] = '_menuorder._tcp'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['ENABLE_PREVIEWS'] = 'YES'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

project.save

puts "✅ MenuServer target added successfully"
