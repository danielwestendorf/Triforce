#
#  ImgBrowser.rb
#  Triforce
#
#  Created by Daniel Westendorf on 7/25/11.
#  Copyright 2011 Daniel Westendorf. All rights reserved.
#

class ImgBrowser
    attr_accessor :parent, :assets, :image_browser_view
    
    def awakeFromNib
        @assets = [Asset.new("/Users/dwestendorf/Desktop/1.jpg"), Asset.new("/Users/dwestendorf/Desktop/2.jpg"), Asset.new("/Users/dwestendorf/Desktop/1.jpg"), Asset.new("/Users/dwestendorf/Desktop/2.jpg"), Asset.new("/Users/dwestendorf/Sites/scott-sports.com/css/style.css")]
        #set image browser options
        @image_browser_view.animates = true
        @image_browser_view.setCanControlQuickLookPanel(true)
        @image_browser_view.setCellsStyleMask(12)
        @image_browser_view.setAllowsMultipleSelection(false)
        @image_browser_view.setAllowsReordering(false)
        
        self.refresh
    end

    def numberOfItemsInImageBrowser(view)
        return @assets.length
    end
    
    def imageBrowser(view, itemAtIndex: index)
        return @assets[index]
    end
    
    def refresh
        @assets.sort_by! {|a| a.path}
        @image_browser_view.reloadData
    end
    
    #zoom buttons
    def zoom_in(sender)
        current_zoom = @image_browser_view.zoomValue
        if current_zoom + 0.1 < 1.0
            @image_browser_view.setZoomValue(current_zoom + 0.1)
        elsif current_zoom < 1.0
             @image_browser_view.setZoomValue(1.0)
        end
    end
    
    def zoom_out(sender)
        current_zoom = @image_browser_view.zoomValue
        if current_zoom - 0.1 > 0.0
            @image_browser_view.setZoomValue(current_zoom - 0.1)
            elsif current_zoom > 0.0
            @image_browser_view.setZoomValue(0.0)
        end
    end
    
end
