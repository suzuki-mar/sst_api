# frozen_string_literal: true

module V1
  class Root < Grape::API
    version :v1
    format :json

    mount V1::SelfCareClassifications

    add_swagger_documentation(
      doc_version: '0.0.1',
      info: {
        title: 'sst-api APIDoc',
        description: 'sst-apiのAPIドキュメント'
      }
    )
  end
end
