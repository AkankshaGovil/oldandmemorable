import java.io.File;
import java.io.FileInputStream;

import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;
import javax.xml.namespace.QName;

import org.jboss.axis.client.Call;
import org.jboss.axis.client.Service;

import com.nextone.generated.common.CredentialsType;
import com.nextone.generated.common.ErrorOptionType;
import com.nextone.generated.generateroutes.Reply;
import com.nextone.generated.importroutes.ConfigType;
import com.nextone.generated.importroutes.EditConfig;
import com.nextone.generated.importroutes.EditConfigConfigImportConfigCommand;
import com.nextone.generated.importroutes.ImportConfigType;


public class ImportRoutes {
	protected Call call;
	/**
 	* Import customer routes
 	* @throws Exception
 	*/
	    public void testImportCustomerRoutes() throws Exception{
	    	//correct the file path
		  	//executeRequest("/home/nextone_src/43main/bn/ivmstest/testcustomerroutes.txt","importCustomerRoutes");
	    	executeRequest(importFilePath, importType);	    	
	    }

	/**
 	* Utility method to execute web service requests
 	* @param filename FileName to be imported
 	* @param methodName Method To be Executed
 	* @throws Exception
 	*/
	public void executeRequest(String filename,String methodName) throws Exception {
                //System.setProperty("javax.net.ssl.trustStore", "/opt/nxtn/jboss/server/default/conf/client.truststore");
                //System.setProperty("javax.net.ssl.trustStorePassword", "shipped!!");
		EditConfig edConf = new EditConfig();
		System.out.println(filename);
		ConfigType conf = new ConfigType();
		//correct the credentials
		CredentialsType credentialsType = new CredentialsType();
		credentialsType.setPartition("admin");
		credentialsType.setPassword(userPassword);
		credentialsType.setUser("root");

		ImportConfigType ict = new ImportConfigType();
		if("add".equalsIgnoreCase(operation)){
			ict.setCommand(EditConfigConfigImportConfigCommand.add);
		}else{
			ict.setCommand(EditConfigConfigImportConfigCommand.replace);
		}
		ict.setDelimiter(";");
		ict.setPartition("admin");
		ict.setDevicename(deviceName);

		conf.setCredential(credentialsType);

		conf.setImportConfig(ict);

		edConf.setConfig(conf);

		edConf.setErrorOption(ErrorOptionType.value1);

		/**
		 * create the Mime multipart to represent the attachment. The file name
		 * to be imported will be passed as an first argument to the function
		 */

		FileInputStream fis = new FileInputStream(new File(
				filename));
		MimeBodyPart bPart = new MimeBodyPart(fis);
		MimeMultipart mpart = new MimeMultipart();
		mpart.addBodyPart(bPart);
		
		String url = "https://localhost:443/rsm/ws/prov/importroutes";
		System.out.println(url);
		call = (Call) new Service().createCall();
		call.setTargetEndpointAddress(url);
		call.setOperationName(methodName);
		setImportRoutes(call);

		Object rep = call.invoke(new Object[] { edConf, mpart });
		System.out.print(rep);
		if(rep instanceof String)
			System.out.println("Reply Status:" + rep);
		else{
			Reply reply = (Reply) rep;
			System.out.println("Reply Status:"+reply.getOk());
		}
	}

	private void setImportRoutes(Call call) {
		QName qn = new QName("http://www.nextone.com/ivms/schema/common",
				"ErrorSeverity", "ns1");
		call.registerTypeMapping(
				com.nextone.generated.common.ErrorSeverity.class, qn,
				org.jboss.axis.encoding.ser.EnumSerializerFactory.class,
				org.jboss.axis.encoding.ser.EnumDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common", "ErrorTag",
				"ns1");
		call.registerTypeMapping(com.nextone.generated.common.ErrorTag.class,
				qn, org.jboss.axis.encoding.ser.EnumSerializerFactory.class,
				org.jboss.axis.encoding.ser.EnumDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"ErrorType", "ns1");
		call.registerTypeMapping(
				com.nextone.generated.common.ErrorTypes.class, qn,
				org.jboss.axis.encoding.ser.EnumSerializerFactory.class,
				org.jboss.axis.encoding.ser.EnumDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"credentialsType", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.common.CredentialsType.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"dataErrorInfo", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.common.DataErrorInfo.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"errorInfoType", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.common.ErrorInfoType.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"errorOptionType", "ns1");
		call.registerTypeMapping(
				com.nextone.generated.common.ErrorOptionType.class, qn,
				org.jboss.axis.encoding.ser.EnumSerializerFactory.class,
				org.jboss.axis.encoding.ser.EnumDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/common",
				"errorType", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.common.ErrorType.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/config",
				"configType", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.importroutes.ConfigType.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/config",
				"editConfig", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.importroutes.EditConfig.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/config",
				"editConfig-config-importConfig-command", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.importroutes.EditConfigConfigImportConfigCommand.class,
						qn,
						org.jboss.axis.encoding.ser.EnumSerializerFactory.class,
						org.jboss.axis.encoding.ser.EnumDeserializerFactory.class);

		qn = new QName("http://www.nextone.com/ivms/schema/config",
				"importConfigType", "ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.importroutes.ImportConfigType.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);

		/*qn = new QName("http://www.nextone.com/ivms/schema/config", "reply",
				"ns1");
		call
				.registerTypeMapping(
						com.nextone.generated.importroutes.Reply.class,
						qn,
						org.jboss.webservice.encoding.ser.MetaDataBeanSerializerFactory.class,
						org.jboss.webservice.encoding.ser.MetaDataBeanDeserializerFactory.class);*/

	}
	
	public static void usage(){
		System.out.println("ImportRoutes <import file path> <importtype> <devicename> <userPassword> <operation add|replace>");
		System.exit(1);
	}
	private static String importType = null;
	private static String importFilePath = null;
	private static String deviceName = null;
	private static String userPassword = null;
	private static String operation = null;
	
	public static void main(String args[]) throws Exception{
		//filename
		//importtype
		//devicename
		//username [root]
		//password [shipped!!]
		//partition [admin]
		if(args.length < 5){
			usage();
		}
		if(args[0] == null || args[0].trim().equals("")){
			usage();
		} else {
			importFilePath = args[0];
		}
		
		if(args[1] == null || args[0].trim().equals("")){
			usage();
		} else {
			importType = args[1];
		}
		
		if(args[2] == null || args[2].trim().equals("")){
			usage();
		} else {
			deviceName = args[2];
		}		
		
		if(args[3] == null || args[3].trim().equals("")){
			usage();
		} else {
			userPassword = args[3];
		}		
		
		if(args[4] == null || args[4].trim().equals("")){
			usage();
		} else {
			operation = args[4];
		}		
		ImportRoutes routes = new ImportRoutes();
		routes.testImportCustomerRoutes();
		System.out.println("success");
		
	}
}

