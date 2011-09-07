#
#  ImgBrowser.rb
#  Triforce
#
#  Created by Daniel Westendorf on 7/25/11.
#  Copyright 2011 Daniel Westendorf. All rights reserved.
#

class ImgBrowser
    attr_accessor :parent, :assets, :image_browser_view
    
    def initialize
        @fs_queue = Dispatch::Queue.new('it.Triforce.fs')
    end
    
    def awakeFromNib
        @image_browser_view.registerForDraggedTypes(NSArray.arrayWithObjects(NSFilenamesPboardType, nil))
        @image_browser_view.setDraggingDestinationDelegate(self)
        @image_browser_view.scrollIndexToVisible(0)
        
        @assets = []
        @asset_list = []
        #set image browser options
        @image_browser_view.animates = true
        @image_browser_view.setCanControlQuickLookPanel(true)
        @image_browser_view.setCellsStyleMask(12)
        @image_browser_view.setAllowsEmptySelection(false)
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
    
    #delegate methods
    def imageBrowserSelectionDidChange(browser)
        @parent.asset_attributes.reload_attributes
    end
    
    def imageBrowser(browser, writeItemsAtIndexes:indexes, toPasteboard:pboard)
        return 0 #don't allow drag'n drop within the imagebrowser
    end
    
    def imageBrowser(browser, cellWasDoubleClickedAtIndex:index)
        asset = @assets[@image_browser_view.selectionIndexes.lastIndex]
        asset.o_status == 2 ? path = asset.o_path : path = asset.path
        NSWorkspace.sharedWorkspace.selectFile(path, inFileViewerRootedAtPath:nil)
    end
    
    #drag'n drop code
    def draggingEntered(sender)
        puts "Drag entered"
        @image_browser_view.setDropIndex(@assets.length, dropOperation:IKImageBrowserDropBefore)
        @image_browser_view.setDropIndex(@assets.length, dropOperation:IKImageBrowserDropOn)
        pboard = sender.draggingPasteboard
        
        if pboard.types.containsObject(NSFilenamesPboardType)
            return NSDragOperationLink
        else
            return NSDragOperationNone
        end
    end
    
    def draggingUpdated(sender)
        @image_browser_view.setDropIndex(@assets.length, dropOperation:IKImageBrowserDropBefore)
        @image_browser_view.setDropIndex(@assets.length, dropOperation:IKImageBrowserDropOn)
        true
    end
    
    def prepareForDragOperation(sender)
        pboard = sender.draggingPasteboard
        has_valid_asset = false
            
        pboard.propertyListForType(NSFilenamesPboardType).each do |file|
            if !@asset_list.include?(file) && (File.directory?(file) || valid_asset?(file))
                has_valid_asset = true
                break
            end
        end
        
        return has_valid_asset
    end
    
    def performDragOperation(sender)
        pboard = sender.draggingPasteboard
        
        if pboard.types.containsObject(NSFilenamesPboardType)
            pboard.propertyListForType(NSFilenamesPboardType).each do |file|
                @fs_queue.sync do
                    if File.directory?(file)
                        Dir.glob(file + "/**/*").each do |file|
                           add_asset(file) if valid_asset?(file) 
                        end
                    elsif valid_asset?(file)
                        add_asset(file)
                    end
                end
                refresh
            end
        end
        return true
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
    
    private
    
    def add_asset(file)
        return if @asset_list.include?(file)
        @asset_list << file
        @assets << Asset.new(file)
    end
    
    def valid_asset?(path)
        uti = NSWorkspace.sharedWorkspace.typeOfFile(path, error: nil)
        return false unless uti
        if ["jpeg", "png", "css", "javascript-source"].include?(uti.split(".").last)
            return true
        end
    end
    
end
