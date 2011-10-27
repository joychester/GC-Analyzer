require 'csv'

def gcanalyzer(filename)
i = File.new(filename);
arr1 = [0];
arr2 = [];
@@maxpasuetime = 0.0000;
@@fullgc_count = 0;

m = 0;

endstamp = i.mtime
if (!endstamp.isdst) #Summer Time
  zone = 15
else
  zone = 16
end
a = i.readlines()
endsec = a[a.count-1].to_i

outputfilename = 'GC_log' + endstamp.strftime("_%m-%d-%H%M%S") + '.csv';

j = File.new(filename);
open(outputfilename, "a"){|f|
  j.each_line { |line|
    if (s = line.split('->')[2])!= nil
      offset = endsec - line.split(':')[0].to_i

      ctime = endstamp - offset -zone*3600

      timestamp = ctime.strftime("%m/%d-%H:%M:%S")
      usedheap = s.split('K(')[0]
      f <<  timestamp + "," + usedheap + "\n"

      #prepare pause time
      # This is for +UseParallelGC
      if line =~/PSYoungGen/
        
        if line =~ /Full/
            @@fullgc_count = @@fullgc_count + 1
            arr2.push(timestamp);
        end
        t1 = line.split(',')[1]

      elsif  # This is for CMS case

        if line =~ /Full/
            @@fullgc_count = @@fullgc_count + 1
            arr2.push(timestamp);
            t1 = line.split(',')[3]
        elsif
            t1 = line.split(',')[2]
        end

      end
      pausetime = t1.split('secs')[0].strip.to_f
      arr1[0] = arr1[0] + pausetime

      #prepare maxpausetime
      if pausetime > @@maxpasuetime
          @@maxpasuetime = pausetime;
      end

    end
  }
}

elapsedday = endsec/(24*3600);
ed = (endsec - elapsedday*24*3600);
elapsedhour = ed/3600;
elapsedmin = (ed - elapsedhour*3600)/60;

printf("Total Elapse Time: %d (%dday-%dhour-%dmin)\n", endsec, elapsedday, elapsedhour,elapsedmin) ;
printf("Total GC Puase Time: %.3f \n" , arr1[0]) ;
printf("GC Throughput: %.3f \n" ,(1-arr1[0]/endsec)*100) ;
printf("Max Pause Time: %.3f \n",@@maxpasuetime) ;
printf("Avg Puase Time: %.3f \n", (arr1[0]/(a.count-1)));
printf("Total GC Occurency: %d \n", (a.count-1));
printf("GC Frenquency: %.3f \n", endsec/(a.count-1));
printf("Full GC Occurency: %d \n", @@fullgc_count);
printf("Full GC Time stamp: #{arr2}");

# consider to make a chart based on new file in the future

end

gcanalyzer(ARGV[0]);