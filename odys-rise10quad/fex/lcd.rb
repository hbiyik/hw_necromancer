#!/usr/bin/env ruby

if !ARGV[0] || !File.exists?(ARGV[0]) then
  abort "Usage: ruby #{__FILE__} [fex_file_name]\n"
end

def parse_fex_section(filename, section)
  results = {}
  current_section = ""
  File.open(filename).each_line {|l|
    current_section = $1 if l =~ /^\[(.*?)\]/
    next if current_section != section
    results[$1] = $2.strip if l =~ /^(\S+)\s*\=\s*(.*)/
    results[$1] = $2.to_i if l =~ /^(\S+)\s*\=\s*(\d+)\s*$/
  }
  return results
end

def print_video_lcd_mode(lcd0_para, vt_div)
  x        = lcd0_para["lcd_x"]
  y        = lcd0_para["lcd_y"]
  depth    = { 0 => 24, 1 => 18 }[lcd0_para["lcd_frm"]]
  pclk_khz = lcd0_para["lcd_dclk_freq"] * 1000
  hs       = [1, (lcd0_para["lcd_hv_hspw"] || lcd0_para["lcd_hspw"])].max
  vs       = [1, (lcd0_para["lcd_hv_vspw"] || lcd0_para["lcd_vspw"])].max
  le       = lcd0_para["lcd_hbp"] - hs
  ri       = lcd0_para["lcd_ht"] - x - lcd0_para["lcd_hbp"]
  up       = lcd0_para["lcd_vbp"] - vs
  lo       = lcd0_para["lcd_vt"] / vt_div - y - lcd0_para["lcd_vbp"]

  abort "Unsupported 'lcd_frm' parameter" if !depth

  printf("CONFIG_VIDEO_LCD_MODE=\"" +
         "x:#{x},y:#{y},depth:#{depth},pclk_khz:#{pclk_khz}," +
         "le:#{le},ri:#{ri},up:#{up},lo:#{lo},hs:#{hs},vs:#{vs}," +
         "sync:3,vmode:0\"\n")
end

lcd0_para = parse_fex_section(ARGV[0], "lcd0_para")
abort "Not a valid 'lcd0_para' section" if lcd0_para["lcd_used"] != 1

printf("== for sun[457]i ==\n")
print_video_lcd_mode(lcd0_para, 2)

printf("\n== for sun[68]i ==\n")
print_video_lcd_mode(lcd0_para, 1)
