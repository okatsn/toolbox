mail = 'automaton.py@gmail.com'; 
password = 'benqs700tomato';
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.starttls.enable','true');
%props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');

props.setProperty('mail.smtp.socketFactory.port','465');
% smtp.gmail.com uses port 465 (SSL) or 587 (TLS), so you need to specify port number.
target = 'okatsn@gmail.com';
title1 = 'test';
content = ['Test from MATLAB','Hello! This is a test from MATLAB!'];

sendmail(target,title1,content);