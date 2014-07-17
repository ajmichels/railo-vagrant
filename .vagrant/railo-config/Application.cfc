component
{


	this.name = "VagrantRailoConfig";


	variables.adminPassword = "**MY_ADMIN_PASSWORD**";


	public function onRequestStart()
	{
		setting requesttimeout="500";

		param name="url.type" default="";

		if (url.type == "" || url.type == "mappings") {
			configMappings();
		}

		if (url.type == "" || url.type == "datasources") {
			configDatasources();
		}

		if (url.type == "" || url.type == "caches") {
			configCaches();
		}

		if (url.type == "" || url.type == "debugging") {
			configDebugging();
		}

		if (url.type == "" || url.type == "mail") {
			configMail();
		}

	}


	private void function configMappings()
	{
		var mappings = [
			{virtual="/com",  physical="/mnt/com"},
		];

		for (mapping in mappings) {
			admin action="updateMapping" type="server" password=variables.adminPassword
				virtual=mapping.virtual
				physical=mapping.physical
				archive="no"
				primary="physical"
				toplevel="false"
				trusted="false";
		}

	}


	private void function configDatasources()
	{
		mySqlDsn = "jdbc:mysql://{host}:3306/{database}";

		datasources = [
			{
				classname="org.gjt.mm.mysql.Driver",
				host="127.0.0.1",
				name="myDatabase",
				username="root",
				password="",
				dsn=mySqlDsn
			},
		];

		for (ds in datasources) {
			try {
				admin action="updateDatasource" type="server" password=variables.adminPassword
					name=ds.name
					newName=ds.name
					database=ds.name
					dbusername=ds.username
					dbpassword=ds.password
					classname=ds.classname
					host=ds.host
					dsn=ds.dsn;
			}
			catch (any e) {
				writeOutput(e.message & " " & chr(10));
			}

		}

	}


	private void function configCaches()
	{
		var cacheSettings = {
			timeToIdleSeconds    = 86400,
			maxelementsinmemory  = 10000,
			maxelementsondisk    = 10000000,
			diskpersistent       = true,
			timeToLiveSeconds    = 86400,
			overflowtodisk       = true,
			memoryevictionpolicy = "LRU"
		};

		var caches = [
			{
				name        = "defaultEhcache",
				class       = "railo.runtime.cache.eh.EHCacheLite",
				storage     = "no",
				"read-only" = "false",
				default     = "object",
			},
		];

		for (var cache in caches) {
			cache.custom = cacheSettings;
			admin action="updateCacheConnection" type="server" password=variables.adminPassword
				attributeCollection=cache;

		}

	}


	private void function configDebug()
	{
		var template  = {
			label     = "default",
			debugtype = "railo-classic",
			iprange   = "*",
			fullname  = "railo-context.admin.debug.Classic",
			path      = "/railo-context/admin/debug/Classic.cfc",
			custom    = {
				scopes    = "Application,CGI,Client,Cookie,Form,Request,Server,Session,URL",
				color     = "black",
				font      = "Times New Roman, Times, serif",
				minimal   = 250000,
				highlight = 250000,
				bgcolor   = "white",
				general   = true,
				size      = "medium",
			},

		};

		var settings = {
			debug          = true,
			database       = false,
			exception      = true,
			tracing        = true,
			timer          = true,
			implicitAccess = false,
			queryUsage     = false,
			debugTemplate  = template.label,
		};

		admin action="updateDebugEntry" type="server" password=variables.adminPassword
			attributeCollection=template;

		admin action="updateDebug" type="server" password=variables.adminPassword
			attributeCollection=settings;

	}


	private void function configMail()
	{
		admin action="updateMailServer" type="server" password=variables.adminPassword
			hostname="127.0.0.1"
			dbusername=""
			dbpassword=""
			port="25"
			id="#hash("127.0.0.1:_:_:false:false")#"
			tls="false"
			ssl="false"
			remoteClients="#arrayNew(1)#";

	}


}
