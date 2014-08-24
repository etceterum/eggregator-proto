# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  class PageLink
    attr_reader :page, :ranges

    def initialize(page, ranges)
      @page = page
      @ranges = ranges
    end

    def page0
      @page - 1
    end
  end

  class PageLinkGroup
    attr_reader :page_links

    def self.separator
      PageLinkGroup.new
    end

    def initialize
      @page_links = []
    end

    def <<(page_link)
      @page_links << page_link
    end

    def separator?
      @page_links.empty?
    end

  end

  PAGE_RANGE_NAMES = ['begin', 'current', 'end']

  # current_page is 0-based
  def page_link_groups(page_count, current_page0)
    # how many page links to display at the beginning (3 means pages 1, 2, 3 will be displayed)
    first_count = 3
    # how many page links to display at the end of the list (3 means pages n-3, n-2, n-1 will be displayed)
    last_count = 2
    # how many pages to display before the current page (2 means pages i-2, i-1 will be displayed)
    before_count = 3
    # how many pages to display after the current page (2 means pages i+1, i+2 will be displayed)
    after_count = 3

    last_page = page_count - 1
    if current_page0 < 0
      current_page0 = 0
    elsif current_page0 > last_page
      current_page0 = last_page
    end

    full_range = 1..page_count

    ranges = [ 
      adjust_page_range(1..first_count, full_range), 
      adjust_page_range((current_page0 - before_count + 1)..(current_page0 + after_count + 1), full_range),
      adjust_page_range((last_page - last_count + 1)..page_count, full_range)
      ]


    page_ranges = {}
    ranges.each_with_index do |range, i|
      range.each do |page|
        page_ranges[page] ||= []
        page_ranges[page] << i
      end
    end

    link_groups = []
    previous_page = nil
    current_link_group = nil
    page_ranges.keys.sort.each do |page|
      if previous_page.nil? || previous_page != page - 1
        # gap detected - need to flush the current link group and start a new one
        unless link_groups.empty?
          # insert a separator
          link_groups << PageLinkGroup.separator
        end
        link_groups << current_link_group unless current_link_group.nil?
        current_link_group = PageLinkGroup.new
      end
      current_link_group << PageLink.new(page, page_ranges[page].collect { |i| PAGE_RANGE_NAMES[i] })
      previous_page = page
    end
    unless current_link_group.nil?
      unless link_groups.empty?
        # insert a separator
        link_groups << PageLinkGroup.separator
      end
      link_groups << current_link_group unless current_link_group.nil?
    end

    link_groups
  end

  def title
    ['agg.regat.org'].concat(@title || []).join(' | ')
  end
  
  private

  def adjust_page_range(range, container_range)
    if range.begin < container_range.begin
      # if sticks out on the left hand side, push to the right
      range = container_range.begin..(range.end + container_range.begin - range.begin)
    end
    if range.end > container_range.end
      # if sticks out on the right hand side, push to the left
      range = (range.begin - (range.end - container_range.end))..container_range.end
    end
    if range.begin < container_range.begin
      # seems like the range is bigger than the container
      range = container_range
    end
    range
  end

end

