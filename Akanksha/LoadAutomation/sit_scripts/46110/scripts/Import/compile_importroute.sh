export classpath=/opt/nxtn/jboss/server/default/deploy/iview.war/nexcommon.jar
export classpath=$classpath:/opt/nxtn/jboss-4.0.3SP1/client/mail.jar:/opt/nxtn/jboss-4.0.3SP1/client/jboss-ws4ee-client.jar
export classpath=$classpath:/opt/nxtn/jboss-4.0.3SP1/client/jbossall-client.jar:/opt/nxtn/jboss-4.0.3SP1/client/activation.jar
export classpath=$classpath:/opt/nxtn/jboss-4.0.3SP1/client/commons-discovery.jar:/opt/nxtn/jboss-4.0.3SP1/client/commons-logging.jar
export classpath=$classpath:/opt/nxtn/jboss-4.0.3SP1/client/axis-ws4ee.jar:/opt/nxtn/jboss-4.0.3SP1/client/wsdl4j.jar
export classpath=$classpath:/opt/nxtn/jboss/server/default/deploy/iview.war/client-config.jar
export classpath=$classpath:./importroutes.jar
export classpath=$classpath:/opt/nxtn/jboss/server/default/deploy/iview.war/iView.jar

echo $classpath

/opt/nxtn/jdk/bin/javac -cp "$classpath" ImportRoutes.java


/opt/nxtn/jdk/bin/jar -cvf importroutes.jar *.class
