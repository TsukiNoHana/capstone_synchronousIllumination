function displayobjRunMode(inbytes,handles)
% Function that displays the sensor's image. First grabs the values from
% the sensor and reshapes them in a 3 dimensions vector.
global fullimage lock w h FPGA caliRed caliGreen caliBlue A B C frameOrder record v r g b Aimg Bimg Cimg input oldput previmg scalered scalegreen scaleblue

hbytes = double(inbytes.GetImageData.GetRawPixels1Byte);
img = reshape(hbytes(), [250,250]).';
different = find(img ~= previmg);

if (size(different,1) > 58500)

    previmg = img;
    
    while true
        input = readmemory(FPGA,16400,1);
        pause(0.0001);
        if (input ~= oldput)
            oldput = input;
            break;
        end       
    end
    
%     while true
%         hbytes = double(inbytes.GetImageData.GetRawPixels1Byte);
%         img = reshape(hbytes(), [250,250]).';
%         different = find(img ~= previmg);
%         pause(0.0001);
%         if (size(different,1) >= 40000)
%             previmg = img;
%             break;
%         end
%     end   

% if (size(different,1) < 10000)
%if (isequal(img,previmg))
%if (abs(img-previmg) <= ( 0.08*max(abs(img),abs(previmg)) + eps))
%if (mean(img~=previmg) < 0.25)
%     pause(0.001);
% elseif (size(different,1) >= 10000)
%    previmg = img;



    switch input
        case 10 %Blue off, red on
            if ((size(find(hbytes ~= B),2) < 57500) || (size(find(hbytes ~= C),2) < 57500))
                pause(0.001);
            else
            A = hbytes;
            Aimg = img;
            end
        case 11 %red off, green on
            if ((size(find(hbytes ~= A),2) < 57500) || (size(find(hbytes ~= C),2) < 57500))
                pause(0.001);
            else
            B = hbytes;
            Bimg = img;
            end
        case 12 %green off, blue on
            if ((size(find(hbytes ~= A),2) < 57500) || (size(find(hbytes ~= B),2) < 57500))
                pause(0.001);
            else
            C = hbytes;
            Cimg = img;
            end
        case 13
            disp("Error in FPGA code");
        otherwise
            disp("Something's wrong");
    end
   
    
%     if (input == 10) %Blue off, red on
%             A = hbytes;
%             Aimg = img;
%     elseif (input == 11) %red off, green on
%             B = hbytes;
%             Bimg = img;
%     elseif (input == 12) %green off, blue on
%             C = hbytes;
%             Cimg = img;
%     elseif (input == 13)
%         disp("Error in FPGA code");
%     else
%         disp("Something's wrong");
%     end

    ABC = cat(2,A.',B.',C.');
    Red = sum(ABC.*caliRed,2);
        r = scalegreen*reshape(Red(), [w,h]); %actually green
    Green = sum(ABC.*caliGreen,2);
        g = scaleblue*reshape(Green(), [w,h]); %actually blue
    Blue = sum(ABC.*caliBlue,2);
        b = scalered*reshape(Blue(), [w,h]); %actually red

    if frameOrder == 1
        imgh = cat(3, r,g,b);
    elseif frameOrder == 2
        imgh = cat(3, g,b,r);
    elseif frameOrder == 3
        imgh = cat(3, b,r,g);
    end

    imgh(imgh > 1) = 1;
    imgh(imgh < 0) = 0;

    if record == 1
        writeVideo(v,imgh);
        pause(0.0001);
    else
    end

    set(handles.image,'CData',imgh);
    fullimage=imgh;

    if lock == 3
        setgraph(handles,handles.axes2);
    else  
    end
else
    pause(0.001);
end
end
