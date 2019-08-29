# frozen_string_literal: true

module V1
  class Root < Grape::API
    helpers ApiHelpers
    version :v1
    format :json

    mount V1::SelfCareClassifications
    mount V1::SelfCares

    add_swagger_documentation(
      doc_version: '0.0.1',
      info: {
        title: 'sst-api APIDoc',
        description: 'sst-apiのAPIドキュメント'
      }
    )
  end
end
