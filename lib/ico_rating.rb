# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'ico_rating/version'
require 'http'
require 'nokogiri'

# icorating.com is returning SSL errors: certificate verify failed
# Don't ever do this, but we are only scraping so YOLO
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class IcoRating
  BASE_URL = 'https://icorating.com'

  class << self
    # @return [Hash] All icos
    # @see https://icorating.com/ico/?filter=all
    def all
      parsed_response('all')
    end

    # @return [Hash] Pre-icos
    def preico
      parsed_response('preico')
    end

    # @return [Hash] Completed icos
    def past
      parsed_response('past')
    end

    # @return [Hash] Upcoming icos
    def upcoming
      parsed_response('upcoming')
    end

    # @return [Hash] Ongoing icos
    # @see https://icorating.com/ico/?filter=all
    def ongoing
      parsed_response('ongoing')
    end

    private

    # @param filter [String] icorating.com query filter
    # @return [Hash]
    def parsed_response(filter)
      url = "#{BASE_URL}/ico/?filter=#{filter}"
      request_time = Time.now.to_f
      response = HTTP.get(url, ssl_options)
      html = Nokogiri::HTML(response.body.to_s)
      tables = html.css('table.uk-table:not(.search-element)')
      return {} if tables.blank?

      icos = []

      tables.each do |t|
        # expert reviews are of category 'Rating'
        # unweighted basic reviews are set as 'Basic Review'
        expert = t.css('thead th')[5].text.strip.eql?('Rating')

        # iterate table rows
        t.css('tbody tr').each { |r| icos << parse_ico_row(r, expert) }
      end

      {
        response_code: response.code,
        response_time: (Time.now.to_f - request_time.to_d).to_f,
        count: icos.count,
        icos: icos
      }
    end

    # @param row [Nokogiri<HTML>]
    # @param expert [Boolean] Expert review
    # @return [Hash]
    def parse_ico_row(row, expert)
      td = row.css('td')
      dates = td[2].text.strip.split('-')
      symbol = td[1].text[/\((.+)\)/, 1]

      {
        name: symbol.blank? ? td[1].text : td[1].text[/(.+)\(/, 1].strip,
        symbol: symbol,
        url: row.attr('data-href'),
        ico_start: parse_date(dates[0]),
        ico_end: parse_date(dates[1]),
        hype_score: td[3].css('span').presence&.attr('style')&.value[/width\:(.+)\%/, 1]&.to_f,
        risk_score: td[4].css('span').presence&.attr('style')&.value[/width\:(.+)\%/, 1]&.to_f,
        expert_review: expert,
        review_url: td[5].css('a').presence&.attr('href')&.value,
        rating: td[5].presence&.text&.strip,
        industry: td[6].presence&.text&.strip
      }
    end

    def parse_date(date)
      Date.parse(date)
    rescue StandardError
      nil
    end

    def ssl_options
      { ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
    end
  end # self
end
