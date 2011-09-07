#
#  Img.rb
#  Triforce
#
#  Created by Daniel Westendorf on 7/25/11.
#  Copyright 2011 Daniel Westendorf. All rights reserved.
#

class Asset
    attr_accessor :path, :size, :o_path, :o_status, :o_size
    
    def initialize(path)
        @opt_queue = Dispatch::Queue.new('it.Triforce.optimize')
        
        @image_utis = ["png", "jpeg"]
        @path = path
        @uti = get_uti
        
        #get the size
        attributes = NSFileManager.defaultManager.attributesOfItemAtPath(@path, error: nil)
        @size = attributes["NSFileSize"] if attributes
        
        @o_status = 0
        @o_path = "/tmp/" + @path.split("/").last
        @task = NSTask.alloc.init
        NSNotificationCenter.defaultCenter.addObserver(self, selector:'optimization_complete:', name: "NSTaskDidTerminateNotification", object: @task)
        optimize
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
    
    def optimize
        puts "optimizing"
        case @uti
        when "jpeg"
            path = NSBundle.mainBundle.pathForResource("jpegtran", ofType:nil)
            @task.setLaunchPath(path)
            @task.setArguments(["-optimize", "-outfile", @o_path, @path])
            @o_status = 1
            @task.launch
        when "png"
            path = NSBundle.mainBundle.pathForResource("pngcrush", ofType:nil)
            @task.setLaunchPath(path)
            @task.setArguments(["-q", @path, @o_path])
            @o_status = 1
            @task.launch
        when "css"
            @opt_queue.sync do
                File.open(@path, 'r') {|file| File.open(@o_path, 'w').write(CSSMin.minify(file))}
                @task.setLaunchPath("/bin/echo")
                @task.setArguments([" "])
                @o_status = 1
                @task.launch
            end
        when "javascript-source"
            path = NSBundle.mainBundle.pathForResource("jsmin", ofType:nil)
            cat_task = NSTask.alloc.init
            cat_task.setLaunchPath("/bin/cat")
            cat_task.setArguments([@path])
            from_cat = NSPipe.alloc.init
            cat_task.setStandardOutput(from_cat)
            cat_task.launch
            cat_task.waitUntilExit
            
            from_jsmin = NSPipe.alloc.init
            @task.setLaunchPath(path)
            @task.setStandardInput(from_cat)
            @task.setStandardOutput(from_jsmin)
            
            @o_status = 1
            @task.launch
            @task.waitUntilExit
            data = from_jsmin.fileHandleForReading.readDataToEndOfFile
            data.writeToFile(@o_path, atomically:true)
        end
    end
    
    def optimization_complete(note)
        attributes = NSFileManager.defaultManager.attributesOfItemAtPath(@o_path, error: nil)
        @o_size = attributes["NSFileSize"] if attributes
        @o_size > @size ? optimize : @o_status = 2
    end
        
    def get_uti
        uti = NSWorkspace.sharedWorkspace.typeOfFile(@path, error: nil)
        return unless uti
        return uti.split(".").last
    end
    
    def o_size_to_string
        size_string(@o_size)
    end
    
    def size_to_string
        size_string(@size)
    end
    
    def size_string(bytes)
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
