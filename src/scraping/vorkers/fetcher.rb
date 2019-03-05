# coding: utf-8
module Vorkers
  class Fetcher
    def initialize(company_id)
      raise ArgumentError unless company_id.kind_of?(String)
      @company_id = company_id
    end

    def perform
      {
        analysis: company_analysis,
        ranking:  company_ranking,
        review:   review,
        recruit:  recruit
      }
    end

    private

    def company_analysis
      @company_analysis ||= Doc::Analysis.new(@company_id).collect
    end

    def company_ranking
      @company_ranking ||= Doc::CompanyRanking.new(@company_id).collect
    end

    def review
      @review ||= Doc::Review.new(@company_id).collect
    end

    def recruit
      @recruit ||= Doc::Recruit.new(@company_id).collect
    end
  end
end
