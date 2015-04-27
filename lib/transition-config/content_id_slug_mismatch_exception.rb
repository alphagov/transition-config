module TransitionConfig
  class ContentIDSlugMismatchException < RuntimeError
    def initialize(mismatches)
      @mismatches = mismatches
    end

    def to_s
      "These sites have mismatched slugs/content_ids: \n"\
      "#{@mismatches.map { |abbr, (slug, content_id)| "#{abbr}: #{slug} #{content_id}" }.join("\n")}"
    end
  end
end
