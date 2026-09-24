#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate a joshholtz.com OG image from a Jekyll post.
#
# Usage:
#   ruby scripts/generate-og.rb _posts/2026-09-23-my-post.md
#
# Requires ImageMagick. Reads title/image from frontmatter and writes the
# image path declared by the post, so the post remains the source of truth.

require "date"
require "fileutils"
require "yaml"

post_path = ARGV[0]
abort "Usage: #{$PROGRAM_NAME} _posts/YYYY-MM-DD-post.md" unless post_path && File.file?(post_path)

raw = File.read(post_path)
frontmatter = raw.match(/\A---\s*\n(.*?)\n---\s*\n/m)&.captures&.first
abort "No YAML frontmatter found in #{post_path}" unless frontmatter

data = YAML.safe_load(frontmatter, permitted_classes: [Date, Time], aliases: true) || {}
title = data["title"].to_s.strip
image = data["image"].to_s.strip
abort "Missing title in #{post_path}" if title.empty?
abort "Missing image in #{post_path}" if image.empty?

output = image.sub(%r{\A/}, "")
FileUtils.mkdir_p(File.dirname(output))

width = 1200
height = 630
bg = "#18181b"
text = "#f4f4f5"
muted = "#8c8c9e"
amber = "#f59e0b"
grid = "rgba(255,255,255,0.035)"
border = "#3f3f46"

# Wrap conservatively for social previews.
words = title.split
lines = [""]
words.each do |word|
  candidate = [lines.last, word].reject(&:empty?).join(" ")
  if candidate.length > 30 && !lines.last.empty?
    lines << word
  else
    lines[-1] = candidate
  end
end
lines = lines.first(4)
point_size = case lines.length
             when 1 then 76
             when 2 then 70
             when 3 then 62
             else 54
             end

draw = []
(0..width).step(64) { |x| draw << "stroke #{grid} line #{x},0 #{x},#{height}" }
(0..height).step(64) { |y| draw << "stroke #{grid} line 0,#{y} #{width},#{y}" }

# ImageMagick 7 uses magick; Ubuntu's ImageMagick 6 uses convert.
magick = system("command -v magick >/dev/null 2>&1") ? "magick" : "convert"

cmd = [
  magick, "-size", "#{width}x#{height}", "xc:#{bg}",
  "-stroke", grid, "-strokewidth", "1", "-fill", "none", "-draw", draw.join(" "),
  "-fill", "rgba(245,158,11,0.08)", "-stroke", "none",
  "-draw", "circle 600,-180 930,-180",
  "-fill", amber, "-font", "JetBrains-Mono", "-pointsize", "30",
  "-annotate", "+76+105", ">_",
  "-fill", text, "-font", "Inter", "-pointsize", point_size.to_s,
  "-interline-spacing", "-4", "-annotate", "+76+190", lines.join("\n"),
  "-stroke", border, "-strokewidth", "1", "-draw", "line 76,505 1124,505",
  "-stroke", "none", "-fill", muted, "-font", "JetBrains-Mono", "-pointsize", "18",
  "-annotate", "+76+558", "JOSH HOLTZ  /  JOSHHOLTZ.COM",
  "-stroke", amber, "-strokewidth", "2", "-fill", "none",
  "-draw", "roundrectangle 1034,530 1124,574 7,7",
  "-stroke", "none", "-fill", amber, "-font", "JetBrains-Mono", "-pointsize", "17",
  "-annotate", "+1055+558", "BLOG",
  "-quality", "90", output
]

system(*cmd) || abort("Failed to generate #{output}. Install ImageMagick, Inter, and JetBrains Mono.")
puts "Wrote #{output}"
