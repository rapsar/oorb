function [] = blink()
%BLINK Sends email once spherifly3d has completed

try

    sender = 'sphirefly3d@gmail.com';    %sender email
    password = 'bbtr sdre fbbx loab';    %app (Matlab) specific password

    %% Set up Gmail SMTP service.
    % Note: following code found from
    % http://www.mathworks.com/support/solutions/data/1-3PRRDV.html
    % If you have your own SMTP server, replace it with yours.
    % Then this code will set up the preferences properly:
    setpref('Internet','E_mail',sender);
    setpref('Internet','SMTP_Server','smtp.gmail.com'); %smtp.gmail.com
    setpref('Internet','SMTP_Username',sender);
    setpref('Internet','SMTP_Password',password);
    % The following four lines are necessary only if you are using GMail as
    % your SMTP server. Delete these lines wif you are using your own SMTP
    % server.
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.port','465');
    props.setProperty('mail.smtp.socketFactory.port','465');


    recipient = 'raphael.sarfati@aya.yale.edu';
    subject = 'sphirefly3d incoming';
    message = [strcat('spherifly3d was completed at local time:',32,datestr(now)) ...
                newline ...
                pwd];
    % get ip?
    attachment = 'xyztkj.csv'; % or grab latest xyztkj file

    % send email
    try
        sendmail(recipient,subject,message,attachment)
    catch
        sendmail(recipient,subject,message)
    end

catch
end

end


