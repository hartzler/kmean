# simple k-mean impl
k=(ARGV[0]||3).to_i
iterations=(ARGV[1]||10).to_i

# utility functions/patches
class Array
  def sum
    inject(0){|t,v| t+v}
  end
end

def dist(v1,v2)
  Math.sqrt( v1.zip(v2).map{|v| (v[0]-v[1])**2}.sum )
end

def mean(vectors)
  (0..(vectors[0].size-1)).map do |i|
    vectors.map{|v| v[i]}.sum / 2.0
  end
end

# read titles from stdin
titles = $stdin.read.downcase.gsub(/[.,!?'"()]/,'').split("\n").sort{|a,b| rand}
words = titles.map{|t| t.split}.flatten.uniq.sort

# score titles: [ [title, vector], ... ]
scored_titles = titles.map {|t| [t, words.map{|w| t.split.include?(w) ? 1 : 0}] }

# pick k titles for start means
remaining = scored_titles.clone

# [ [ mean vector, [title1, title2, ...]], ...  ]
means = (1..k).map{|i| t=remaining.choice; remaining-=t; [t[1],[t]] }

# calc means a few times
iterations.times do |i|
  scored_titles.sort{|a,b| rand}.each do |t|
    # select nearest mean to this title
    nearest_mean = means.map{|m| [dist(t[1],m[0]),m] }.sort.first.last

    # move title to new nearest_mean
    means.each{|m| m[1] -= [t]}
    nearest_mean[1] += [t]

    # recalc means for means with titles
    means.reject{|m|m[1].empty?}.each{|m| m[0] = mean(m[1].map{|t| t.last}) }
  end 
end

means.each do |m|
  puts
  puts m[1].map{|t| t[0]}.inspect
end
