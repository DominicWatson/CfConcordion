<cfcomponent output="false" extends="util.Base">

<!--- PROPERTIES --->
	<cfscript>
		_javaLoader   = "";
		_javaLibPaths = "";
		_concordion   = "";
		_proxyFactory = "";
	</cfscript>

<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="CfConcordion" output="false">
		<cfscript>
			_initJavaLoader();
			_initProxyFactory();
			_setConcordionOutputDirectory();
			_initConcordion();

			return this;
		</cfscript>
	</cffunction>

<!--- PUBLIC METHODS --->
	<cffunction name="process" access="public" returntype="any" output="false">
		<cfargument name="component" type="any" required="true" />

		<cfscript>
			var htmlSpec           = _getHtmlSpecFromCfc( arguments.component );
			var result             = "";
			var oldClassLoader     = _setThreadClassLoader();

			result = _getConcordion().process( htmlSpec, arguments.component );

			_setThreadClassLoader( oldClassLoader );

			return result;
		</cfscript>
	</cffunction>

<!--- PRIVATE UTILITY METHODS --->
	<cffunction name="_initJavaLoader" access="private" returntype="void" output="false">
		<cfscript>
			var jarPaths = ArrayNew(1);

			// put javaloader into server scope, following advice from the author,
			// due to memory leak issues
			if( not StructKeyExists( server, '_cfConcordionJavaLoader') ){

				jarPaths[1]  = ExpandPath( '/cfconcordion/lib/concordion/concordion-1.4.2.jar');
				jarPaths[2]  = ExpandPath( '/cfconcordion/lib/concordion/lib/xom-1.2.5.jar');
				jarPaths[3]  = ExpandPath( '/cfconcordion/lib/concordion/lib/ognl-2.6.9.jar');
				jarPaths[4]  = ExpandPath( '/cfconcordion/lib/concordion/lib/junit-4.8.2.jar');
				jarPaths[5]  = ExpandPath( '/cfconcordion/lib/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar');

				server['_cfConcordionJavaLoader'] = CreateObject('component', 'lib.javaloader.JavaLoader').init( loadPaths = jarPaths, loadColdFusionClassPath = true );
			}

			_setJavaLoader( server['_cfConcordionJavaLoader'] );
			_setJavaLibPaths( jarPaths );
		</cfscript>
	</cffunction>

	<cffunction name="_initConcordion" access="private" returntype="void" output="false">
		<cfscript>
			var builder            = _getJavaLoader().create('org.concordion.internal.ConcordionBuilder');
			var srcClass           = _getProxyFactory().createInstance( CreateObject('component', 'util.CfMappedSource'), ['org.concordion.api.Source'] );
			var evalFactory        = _getProxyFactory().createInstance( CreateObject('component', 'util.CfcEvaluatorFactory').init( _getJavaLoader() ), ['org.concordion.api.EvaluatorFactory'] );
			var oldClassLoader     = _setThreadClassLoader();

			_setConcordion( builder.withSource( srcClass ).withEvaluatorFactory( evalFactory ).build() );

			_setThreadClassLoader( oldClassLoader );
		</cfscript>
	</cffunction>

	<cffunction name="_getHtmlSpecFromCfc" access="private" returntype="string" output="false">
		<cfargument name="component" type="any" required="true" />

		<cfscript>
			var path = getMetaData(arguments.component).name;

			path = Replace(path, '.', '/', 'all');
			path = ReReplaceNoCase(path, 'test$', '');

			return _getJavaLoader().create('org.concordion.api.Resource').init( '/#path#.html' );
		</cfscript>
	</cffunction>

	<cffunction name="_setThreadClassLoader" access="private" returntype="any" output="false" hint="I replace the current thread class loader with the passed class loader, returning the old loader. If no class laoder is passed, I use the javaloader class loader by default.">
		<cfargument name="classLoader" type="any" required="false" default="#_getJavaLoader().getURLClassLoader()#" />

		<cfscript>
			var thread         = createObject("java", "java.lang.Thread");
			var oldClassloader = thread.currentThread().getContextClassLoader();

			thread.currentThread().setContextClassLoader( arguments.classLoader );

			return oldClassloader;
		</cfscript>
	</cffunction>

	<cffunction name="_setConcordionOutputDirectory" access="private" returntype="string" output="false">
		<cfscript>
			var outputDir = _getConcordionOutputDirectory();

			createObject("java", "java.lang.System").setProperty( 'concordion.output.dir', outputDir );
		</cfscript>
	</cffunction>

	<cffunction name="_getConcordionOutputDirectory" access="private" returntype="string" output="false">
		<cfscript>
			var sysProperty = StructNew();

			// examine ColdFusion scopes for the variable...
			if(StructKeyExists(request, 'cfconcordion_output_dir')){
				return request.cfconcordion_output_dir;
			}
			if(StructKeyExists(session, 'cfconcordion_output_dir')){
				return session.cfconcordion_output_dir;
			}
			if(StructKeyExists(application, 'cfconcordion_output_dir')){
				return application.cfconcordion_output_dir;
			}
			if(StructKeyExists(server, 'cfconcordion_output_dir')){
				return server.cfconcordion_output_dir;
			}

			// not there, get it from java system
			sysProperty.outputDir = createObject("java", "java.lang.System").getProperty( 'concordion.output.dir' );
			if(StructKeyExists(sysProperty, 'outputDir')){
				return sysProperty.outputDir;
			}

			return ListAppend( createObject("java", "java.lang.System").getProperty( 'java.io.tmpdir' ), 'concordion', '/' );
		</cfscript>
	</cffunction>

<!--- ACCESSORS --->
	<cffunction name="_setJavaLoader" access="private" returntype="void" output="false">
		<cfargument name="jl" type="any" required="true" />

		<cfset _javaLoader = arguments.jl />
	</cffunction>
	<cffunction name="_getJavaLoader" access="private" returntype="any" output="false">
		<cfreturn _javaLoader />
	</cffunction>

	<cffunction name="_getJavaLibPaths" access="private" returntype="array" output="false">
		<cfreturn _javaLibPaths>
	</cffunction>
	<cffunction name="_setJavaLibPaths" access="private" returntype="void" output="false">
		<cfargument name="JavaLibPaths" type="array" required="true" />
		<cfset _javaLibPaths = arguments.JavaLibPaths />
	</cffunction>

	<cffunction name="_setConcordion" access="private" returntype="void" output="false">
		<cfargument name="concordion" type="any" required="true" />

		<cfset _concordion = arguments.concordion />
	</cffunction>
	<cffunction name="_getConcordion" access="private" returntype="any" output="false">
		<cfreturn _concordion />
	</cffunction>

	<cffunction name="_initProxyFactory" access="private" returntype="void" output="false">
		<cfset _proxyFactory = _getJavaLoader().create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy") />
	</cffunction>
	<cffunction name="_getProxyFactory" access="private" returntype="any" output="false">
		<cfreturn _proxyFactory />
	</cffunction>
</cfcomponent>