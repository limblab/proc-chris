function success = reFileData(inputPath)
    compName = getenv('computername');
    arch = computer('arch');
   monkeys = dir(inputPath);
   monkeys= monkeys(3:end,:);
   monkeys = monkeys([monkeys.isdir], :);
   for i = 1:length(monkeys)
       disp(['Found monkey folder: ', monkeys(i).name , '\n'])
       monkey = monkeys(i).name;
       dates = dir([inputPath,'\', monkeys(i).name]);
       dates = dates(3:end,:);
       dates = dates([dates.isdir],:);
       for j = 1:length(dates)
          disp(['Found date folder: ', dates(j).name , '\n'])
          date = dates(j).name;
          files = dir([inputPath,monkeys(i).name, '\', dates(j).name, '\']);
          files = files(3:end,:);
          if any(strcmp([files.name], 'Sorted'))
              filesSorted = dir([inputPath,monkeys(i).name, '\', dates(j).name, '\Sorted\']);
              files = [files; filesSorted(3:end, :)];
          end
          fileNames = [files.name];
          for k = 1:length(files)
            disp(['Found file: ', files(k).name , '\n'])

              if contains(files(k).name, 'RW')
                  task = 'RW';
              elseif contains(files(k).name, 'CO')
                  task = 'CO';
              elseif contains(files(k).name, 'OOR')
                  task = 'OOR';
              elseif contains(files(k).name, 'TRT')
                  task = 'TRT';
              else
                  task = 'NoTask';
              end
              path1 = makeFileStructure(monkey, date, task);

              if contains(files(k).name, 'TD')
                  movefile([inputPath,monkeys(i).name,'\', dates(j).name, '\', files(k).name], [path1, '\TD\']);
              elseif contains(files(k).name, 'CDS')
                  movefile([inputPath,monkeys(i).name,'\', dates(j).name, '\', files(k).name], [path1, '\CDS\']);
              elseif (contains(files(k).name, '.nev') | contains(files(k).name, '.ccf') | contains(files(k).name, '.ns1') | contains(files(k).name, '.ns2') | contains(files(k).name, 'ns3') | contains(files(k).name, 'ns4') | contains(files(k).name, 'ns5')) & ~contains(files(k).name, '-sorted')
                  movefile([inputPath,monkeys(i).name,'\', dates(j).name, '\', files(k).name], [path1, '\NEV\']);
              elseif contains(files(k).name, 'neuron')
                  movefile([inputPath,monkeys(i).name,'\', dates(j).name, '\', files(k).name], [path1, '\neuronStruct\']);
              elseif (contains(files(k).name, '.nev') | contains(files(k).name, '.ccf') | contains(files(k).name, '.ns1') | contains(files(k).name, '.ns2') | contains(files(k).name, 'ns3') | contains(files(k).name, 'ns4') | contains(files(k).name, 'ns5')) & contains(files(k).name, '-sorted')
                  movefile([inputPath,monkeys(i).name,'\', dates(j).name, '\Sorted\', files(k).name], [path1, '\NEV\Sorted\']);
              elseif contains(files(k).name, 'color', 'IgnoreCase', true) | contains(files(k).name, 'motion', 'IgnoreCase', true)| contains(files(k).name, 'kinect', 'IgnoreCase', true)| contains(files(k).name, '.trc', 'IgnoreCase', true)| contains(files(k).name, '.sto', 'IgnoreCase', true)| contains(files(k).name, 'markers', 'IgnoreCase', true)| contains(files(k).name, '.mot', 'IgnoreCase', true) |contains(files(k).name, '.mat', 'IgnoreCase', true)
                  movefile([inputPath, monkeys(i).name, '\', dates(j).name, '\', files(k).name], [path1, '\MotionTracking\']);
              end
              
       end
       end
 success = 1;
end