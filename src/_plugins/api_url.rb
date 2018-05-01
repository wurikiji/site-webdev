require 'cgi'

module Jekyll
  module Filters

    # Usage:
    #
    #   api-entry-url | api_url: pub-package-name
    #
    # Example:
    #
    #   'formDirectives-constant' | api_url: 'angular_forms'
    #
    # Result:
    #
    #   https://pub.dartlang.org/documentation/angular_forms/2.0.0-alpha%2B3/angular_forms/formDirectives-constant.html
    #
    # Uses:
    # 
    #  - site.url
    #  - site.data.pkg-vers

    module ApiUrlFilter

      PkgVersFile = 'pkg-vers'

      def api_url(rawApiUri, pkgName)
        apiUrlStart = trim_slashes(Jekyll.configuration({})['api'])
        apiUri = rawApiUri.empty? ? "#{pkgName}-library" : trim_slashes(rawApiUri)
        apiUri += '.html' unless apiUri =~ /\.html$/
        apiUri.gsub!('+', '%2B')

        # Attempt to get the current version of the named package
        site = @context.registers[:site]
        data = site.data[PkgVersFile][pkgName]
        raise ArgumentError, notFound('data', pkgName) unless data
        pkgVers = data['vers']
        raise ArgumentError, notFound('version', pkgName) unless pkgVers

        [apiUrlStart,
         pkgName,
         CGI.escape(pkgVers),
         pkgName,
         apiUri,
        ].join('/')
      end

      def trim_slashes(s)
        s[0] = '' if s.start_with? '/'
        s.chomp('/')
      end

      private

      def notFound(what, pkgName)
        "Package #{what} not found for '#{pkgName}' in #{PkgVersFile}"
      end

    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters::ApiUrlFilter)
