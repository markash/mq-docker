# Navigate to the sample directory and copy the basic_registry.xml into the MQ web directory.
cd /opt/mqm/web/mq/samp/configuration
cp basic_registry.xml /var/mqm/web/installations/Installation1/servers/mqweb

# Inside the basic_registry.xml file, there are some defined access groups we want to use, as well as some other basic configuration.
#
# By default, when we try to run the MQ Console, it will use the contents of the mqwebuser.xml file. 
# As we want to instead use the sample code we just copied, we rename this unwanted file and change the name of basic_registry.xml to mqwebuser.xml:
cd /var/mqm/web/installations/Installation1/servers/mqweb
mv mqwebuser.xml mqwebuser.xml.old
mv basic_registry.xml mqwebuser.xml

# We'll also need write access to this file, which we don't currently have. Let's give ourselves this now.
chmod 640 mqwebuser.xml

# Currently, the console can only be accessed locally. 
# If we want to be able to access our MQ console from any other location, we need to allow this. 
# We can do this with the command line tool setmqweb:
sh /opt/mqm/bin/setmqweb properties -k httpHost -v "*"

# Start MQ Web Console
sh /opt/mqm/bin/strmqweb