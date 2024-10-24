% this script can be used to send yourself an email upon code completion
% WPI email will send it to trash, but gmail works just fine

function [] = misc3_send_email(toEmail, job_id)
% Your Gmail account information
yourEmail = 'guillermo.matlab@gmail.com';        % Your Gmail email address
yourPassword = 'zpfj zhjl mxsi usnn';      % My Gmail APP password (no it's not the real one :D)

% Email details
% toEmail = Recipient's email address
subject = sprintf('Patient: %s Code Execution Completed', job_id); % Email subject
message = sprintf('Your MATLAB code with job ID %s has completed successfully!', job_id); % Email body

% Set up the email configuration
setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
setpref('Internet', 'E_mail', yourEmail);
setpref('Internet', 'SMTP_Username', yourEmail);
setpref('Internet', 'SMTP_Password', yourPassword);

% SMTP server settings for Gmail
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.starttls.enable', 'true');
props.setProperty('mail.smtp.socketFactory.port', '465');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');

% Send the email
sendmail(toEmail, subject, message);
end