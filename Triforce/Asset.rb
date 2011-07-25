#
#  Img.rb
#  Triforce
#
#  Created by Daniel Westendorf on 7/25/11.
#  Copyright 2011 Daniel Westendorf. All rights reserved.
#

class Asset
    attr_accessor :path
    
    def initialize(path)
        @image_utis = ["png", "jpeg"]
        @path = path
        @uti = get_uti
    end
    
    def imageUID
        @path
    end
    
    def imageRepresentationType
        if @image_utis.include?(@uti)
            :IKImageBrowserPathRepresentationType
        else
            :IKImageBrowserNSImageRepresentationType
        end
    end
    
    def imageRepresentation    
        if @image_utis.include?(@uti)
            return @path
        else
            return NSWorkspace.sharedWorkspace.iconForFile(@path)
        end
    end
    
    def imageTitle
        @path.split("/").last
    end
    
    def imageSubtitle
        size_to_string
    end
    
    private
    
    def get_uti
        uti = NSWorkspace.sharedWorkspace.typeOfFile(@path, error: nil)
        return unless uti
        return uti.split(".").last
    end
    
    def size_to_string
        attributes = NSFileManager.defaultManager.attributesOfItemAtPath(@path, error: nil)
        bytes = attributes["NSFileSize"] if attributes
        return unless bytes
        
        return "#{bytes} bytes" if bytes < 1023
        bytes = bytes/1024
        return "#{bytes} KB" if bytes < 1024
        bytes = bytes/1024
        return "#{bytes} MB" if bytes < 1024
        bytes = bytes/1024
        return "#{bytes} GB" if bytes < 1024
        bytes = bytes/1024
        return "#{bytes} TB" if bytes < 1024
        bytes = bytes/1024
        return "#{bytes} PB"
    end
    
end
