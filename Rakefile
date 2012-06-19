desc "Regenerate cookbook metadata.json files"
task :metadata do
  %w[antipackaging stow].each do |name|
    sh "knife cookbook metadata #{name} -o cookbooks"
  end
end
