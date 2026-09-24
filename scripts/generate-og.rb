#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate a joshholtz.com-style OG image for a blog post.
#
# Usage:
#   bundle exec ruby scripts/generate-og.rb "Post title" output.png
#
# Requires ImageMagick's `magick` command. Uses Inter and JetBrains Mono
# when available, matching the site's typography.

require "shellwords"

title = ARGV[0]
output = ARGV[1] || "og.png"

abort "Usage: #{$PROGRAM_NAME} \"Post title\" [output.png]" unless title

width = 1200
height = 630
bg = "#18181b"
text = "#f4f4f5"
muted = "#8c8c9e"
amber = "#f59e0b"
border = "#3f3f46"

# Keep titles readable at social-card sizes.
words = title.split
lines = [""]
words.each do |word|
  candidate = [lines.last, word].reject(&:empty?).join(" ")
  if candidate.length > 31 && !lines.last.empty?
    lines << word
  else
    lines[-1] = candidate
  end
end
lines = lines.first(4)

draw = []
draw << "rectangle 0,0 #{width},#{height}"
# subtle 64px grid, matching the site background
(0..width).step(64) { |x| draw << "stroke rgba(255,255,255,0.035) line #{x},0 #{x},#{height}" }
(0..height).step(64) { |y| draw << "stroke rgba(255,255,255,0.035) line 0,#{y} #{width},#{y}" }

cmd = [
  "magick", "-size", "#{width}x#{height}", "xc:#{bg}",
  "-fill", amber, "-font", "JetBrains-Mono", "-pointsize", "30",
  "-annotate", "+76+105", ">_",
  "-fill", text, "-font", "Inter", "-pointsize", lines.length >= 4 ? "56" : "64",
  "-interline-spacing", "-4",
  "-annotate", "+76+190", lines.join("\n"),
  "-stroke", border, "-strokewidth", "1", "-draw", "line 76,505 1124,505",
  "-stroke", "none", "-fill", muted, "-font", "JetBrains-Mono", "-pointsize", "18",
  "-annotate", "+76+558", "JOSH HOLTZ  /  JOSHHOLTZ.COM",
  "-stroke", amber, "-strokewidth", "2", "-fill", "none", "-draw", "roundrectangle 1034,530 1124,574 7,7",
  "-stroke", "none", "-fill", amber, "-font", "JetBrains-Mono", "-pointsize", "17",
  "-annotate", "+1055+558", "BLOG",
  output
]

system(*cmd) || abort("Failed to generate OG image. Is ImageMagick installed?")
puts "Wrote #{output}"
