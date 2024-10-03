function RotatedAcc = SelectRotateVector(acc)
% Takes the last couple of seconds instead of first couple

% Based on PC Fino's Rotate Vector
% Adapted by SY Cho
% Updated: Jan 31st 2024

    if size(acc,2) ~=3
        acc = acc';
    end
    
    if size(acc,2)~=3
        disp('Acceleration vector must be a nx3 dimensional array');
        return
    end
    
    % takes the last 3s 
    avgAcc = mean(acc(end-(128*3):end,:),1);
    v = [0,0,norm(avgAcc)];

%     switch axeRotate
%         case 1
%             v = [norm(avgAcc),0,0];
%         case 2
%             v = [0,norm(avgAcc),0];
%         case 3
%             v = [0,0,norm(avgAcc)];
%     end

    u = cross(avgAcc,v);
    u = u/norm(u);
    
    theta = acos(dot(avgAcc,v)/(norm(avgAcc)*norm(v)));
    
    q0 = cos(theta/2);
    q123 = sin(theta/2)*u;
    
    q = [q0, q123];
    
    RotatedAcc = RotateVector(acc,q);
end