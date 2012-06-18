task :metadata do
  %w[antipackaging stowify].each do |name|
    sh "knife cookbook metadata #{name} -o cookbooks"
  end
end
