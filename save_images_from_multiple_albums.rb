#!/usr/bin/env ruby
#encoding: UTF-8
require "watir-webdriver"
require "open-uri"
require "watir-webdriver/wait"

@usr = "username@email.domain"
@pswd = "password"
@multipleAlbums = ["http://odnoklassniki.ru/XYZ1/album/12345", 
  "http://odnoklassniki.ru/XYZ2/album/12345", 
  "http://odnoklassniki.ru/XYZ3/album/12345", 
  "http://odnoklassniki.ru/XYZ4/album/12345", ]

b = Watir::Browser.new :firefox

puts "\n** Logging in ..."
b.goto "odnoklassniki.ru"
@usr_field = b.text_field(:id, "field_email")
@pwd_field = b.text_field(:id, "field_password")
@usr_field.when_present.set(@usr)
@pwd_field.set(@pswd)
b.input(:class, "button-pro button-pro_big anonym_login_btn inlineBlock").click
b.span(:id, "portal-headline_login").wait_until_present

for album in 0..@multipleAlbums.size - 1 do
  b.goto @multipleAlbums[album] 
  $total_number_of_photos_in_album = b.span(:class, 'photo-sc_h2_alb-count portlet-i_h2_tx').text.gsub(/\D/, "").to_i 
  @first_image_in_album = b.img(:class, 'photo-sc_i_cnt_a_img va_target')
  @ablum_title = b.span(:class, 'photo-sc_h2_alb-title').text.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub('"','').to_s[0..255]
  puts "\n** Making directory ./" + @ablum_title + "\n"
  FileUtils.mkdir_p @ablum_title
  @first_image_in_album.when_present.click
    
    for photo in 1..$total_number_of_photos_in_album do
      $main_image = b.img(:class => "plp_photo rotate__0deg", :id => "__plpcte_target")
      $still_image = b.img(:id, "__plpcte_target")
      $next = b.div(:class, "plp_slide_outer plp_slide_l_outer")
      $main_image.wait_until_present
      $still_image.wait_until_present
      $next.hover unless $total_number_of_photos_in_album <= 1
      $description = b.span(:id => "plp_descrCntText", :class => "plp_descrCntText").text.to_s[0..100].gsub(/(\d|\/|)|\w/, "").gsub("\n","").gsub('"','')
        File.open(@ablum_title.to_s + "/" + photo.to_s + " " + $description +".jpg", 'wb') do |f|
        f.write open($still_image.src).read
        puts "Saving file number " + photo.to_s + " and title: " + @ablum_title.to_s
    end
    $next.click unless $total_number_of_photos_in_album <= 1
    $main_image.wait_until_present
  end
puts "\n" + $total_number_of_photos_in_album.to_s + " photos saved in ./" + @ablum_title + " folder\n\n"
end
b.close