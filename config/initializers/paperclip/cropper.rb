 require "paperclip"

 module Paperclip
   class Cropper < Thumbnail

     def transformation_command
       if crop_command
         crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ')
       else
         super
       end
     end


     def crop_command
       target = @attachment.instance

       if target.cropping?(@attachment.name)
         w = target.send :"#{@attachment.name}_crop_w"
         h = target.send :"#{@attachment.name}_crop_h"
         x = target.send :"#{@attachment.name}_crop_x"
         y = target.send :"#{@attachment.name}_crop_y"
         ["-crop", "#{w}x#{h}+#{x}+#{y}"]
       end
     end

   end
 end
#module Paperclip
#  class Cropper < Thumbnail
#    def transformation_command
#      if crop_command
#        crop_command + super.sub(/ -crop \S+/, '')
#      else
#        super
#      end
#    end
#
#    def crop_command
#      target = @attachment.instance
#      if target.cropping?
#        " -crop #{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"
#      end
#    end
#  end
#end