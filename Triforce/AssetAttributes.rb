#
#  AssetAttributesDelegate.rb
#  Triforce
#
#  Created by Daniel Westendorf on 7/26/11.
#  Copyright 2011 Daniel Westendorf. All rights reserved.
#
class AssetAttributes
    attr_accessor :image_well, :file_name_field, :file_size_field, :optimized_file_size_field, :percentage_saved_field, :asset_view, :parent
    
    def initialize
        @file_name = ""
        @file_size = "0"
        @optimized_file_size = "0"
        @percentage_saved = "0"
        @image = NSImage.alloc.init
    end
    
    def awakeFromNib
        window_height = @asset_view.superview.frame.size.height
        window_width = @asset_view.superview.frame.size.width
        @asset_view.setFrame(NSRect.new([0, -110], [window_width, 110]))
        @parent.image_browser.image_browser_view.superview.superview.setFrame(NSRect.new([-1, -1], [window_width + 2, window_height + 2]))
        @parent.image_browser.image_browser_view.superview.superview.setNeedsDisplay(true)
    end
    
    def reload_attributes
        hide_attributes_view
    end
        
    def hide_attributes_view
        proc = Proc.new do
            obtain_attributes
            set_attributes
            show_attributes_view
        end
        NSAnimationContext.beginGrouping
        NSAnimationContext.currentContext.setCompletionHandler(proc)
        window_height = @asset_view.superview.frame.size.height
        window_width = @asset_view.superview.frame.size.width
        @asset_view.setFrame(NSRect.new([0, -110], [window_width, 110]))
        @parent.image_browser.image_browser_view.superview.superview.animator.setFrame(NSRect.new([-1, -21], [window_width + 2, window_height + 22]))
        @parent.image_browser.image_browser_view.superview.superview.animator.setNeedsDisplay(true)
        NSAnimationContext.endGrouping
    end
    
    def show_attributes_view
        window_height = @asset_view.superview.frame.size.height
        window_width = @asset_view.superview.frame.size.width
        @asset_view.animator.setFrameOrigin(NSPoint.new(0, 0))
        @parent.image_browser.image_browser_view.superview.superview.animator.setFrameOrigin(NSPoint.new(-1, 110))
        @parent.image_browser.image_browser_view.superview.superview.animator.setFrameSize(NSSize.new(window_width + 2, window_height - 109))
    end
    
    def obtain_attributes
        index = @parent.image_browser.image_browser_view.selectionIndexes.lastIndex
        return unless index
        asset = @parent.image_browser.assets[index]
        @file_name = asset.path
        @file_size = asset.size_to_string
        if asset.imageRepresentationType == :IKImageBrowserPathRepresentationType
           @image = NSImage.alloc.initByReferencingFile(asset.imageRepresentation)
        else
            @image = asset.imageRepresentation
        end
    end
    
    def set_attributes
        @image_well.setImage(@image)
        @file_name_field.setStringValue(@file_name)
        @file_size_field.setStringValue(@file_size)
        @optimized_file_size_field.setStringValue(@optimized_file_size)
        @percentage_saved_field.setStringValue(@percentage_saved)
    end
    
end

