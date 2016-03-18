require 'saml'
require 'corp_pass/providers/base'
require 'corp_pass/response'
require 'corp_pass/providers/stub_logout'

module CorpPass
  module Providers
    class Stub < Base
      include ::CorpPass::Providers::StubLogout

      def sso_idp_initiated_url
        sso_url
      end

      def warden_strategy_name
        :corp_pass_stub
      end

      def warden_strategy
        CorpPass::Providers::StubStrategy
      end

      private

      def sso_url
        url_for controller: :saml, action: :sso_stub, only_path: true
      end
    end

    class InvalidStub < Error; end

    class StubStrategy < BaseStrategy
      include CorpPass::Notification

      USER_ID_REGEX = /^(S|T)([0-9]{7})([A-Z])$/

      def valid?
        notify(CorpPass::Events::STRATEGY_VALID,
               super && !warden.authenticated?(CorpPass::WARDEN_SCOPE) && !params['SAMLart'].blank?)
      end

      def authenticate!
        user_id = params['SAMLart']
        stub_file = read_stub_file(user_id)
        if stub_file
          user = CorpPass::User.new(stub_file)
          begin
            user.validate!
          rescue CorpPass::InvalidUser => e
            notify(CorpPass::Events::INVALID_USER, "User XML validation failed: #{e}\nXML Received was:\n#{e.xml}")
            CorpPass::Util.throw_exception(e, CorpPass::WARDEN_SCOPE)
          end
          notify(CorpPass::Events::LOGIN_SUCCESS, "Logged in successfully #{user.user_id}")
          return success! user
        end

        notify(CorpPass::Events::LOGIN_FAILURE, "Failed reading stub ID #{user_id}")
        CorpPass::Util.throw_exception(CorpPass::Providers::InvalidStub.new, CorpPass::WARDEN_SCOPE)
      end

      private

      def read_stub_file(user_id)
        path = "lib/corp_pass/stub/#{user_id}.xml"
        if !USER_ID_REGEX.match(user_id) || !File.exist?(path)
          notify(CorpPass::Events::LOGIN_FAILURE, "Invalid Stub ID #{user_id}")
          CorpPass::Util.throw_exception(CorpPass::Providers::InvalidStub.new, CorpPass::WARDEN_SCOPE)
        end

        File.read(path)
      end
    end
  end
end
