module MemoriesHelper
  ROW_COLUMNS = 12
  CARD_PATTERN = [ 3, 3, 2, 2, 2, 2, 2, 3, 3, 2 ] # 3 = wide, 2 = narrow
  TAG_COLORS = [ "#6795d6", "#e19593", "#f2de97", "#6d8e6a" ]

  # Zoom levels, indexed 1..4 (1 = default/smallest, 4 = largest). Each value
  # is the row's total column count: shrinking it makes every card (whose
  # span stays 2 or 3) take up a bigger fraction of the row, without changing
  # how cards compare to each other. The max level (9) guarantees at least 3
  # wide cards fit per row (3 * 3 = 9).
  ZOOM_LEVELS = [ 12, 11, 10, 9 ].freeze
  DEFAULT_ZOOM = 1

  TYPE_LABELS = {
    "all" => "Все",
    "photo" => "Фотографии",
    "text" => "Записи"
  }.freeze

  SORT_LABELS = {
    "newest" => "Сначала новые",
    "oldest" => "Сначала старые"
  }.freeze

  def memory_tag_colors
    TAG_COLORS
  end

  # Computes a grid-column span (2 or 3, out of a row_columns-column grid) for
  # each memory, following a decorative wide/narrow rhythm while trying to
  # make each row sum exactly to row_columns (so cards don't leave a gap
  # mid-row). At smaller row_columns (higher zoom) a 2/3 split can't always
  # divide evenly, so a trailing gap is possible and accepted. Pass
  # include_add_space: true to also reserve the first slot for an "add new"
  # card (used on the profile page).
  #
  # Returns { add_space_width:, memory_widths: [] }.
  def memory_grid_widths(memories, include_add_space: false, row_columns: ROW_COLUMNS)
    pattern_index = 0
    row_remaining = row_columns
    slots = [] # { width: }
    flexible_in_row = [] # indices of image cards placed in the current row

    next_pattern_width = -> { w = CARD_PATTERN[pattern_index % CARD_PATTERN.length]; pattern_index += 1; w }

    # Fits a card into the current grid row: use the desired width if it fits,
    # fall back to the alternate width (3<->2, image cards only). If we're
    # short by exactly 1 column, first try upgrading an earlier narrow image
    # card in this row to wide (it absorbs the leftover column and this card
    # starts a fresh row); if none is available, downgrade an earlier wide
    # image card to narrow instead (frees up room for this card to join the
    # row). Otherwise start a new row.
    assign_width = lambda do |desired, allow_alt, adjustable: allow_alt|
      chosen = nil

      if desired <= row_remaining
        chosen = desired
      else
        alt = desired == 3 ? 2 : 3
        if allow_alt && alt <= row_remaining
          chosen = alt
        elsif row_remaining == desired - 1
          upgrade_index = flexible_in_row.reverse.find { |i| slots[i][:width] == 2 }
          if upgrade_index
            slots[upgrade_index][:width] = 3
          else
            downgrade_index = flexible_in_row.reverse.find { |i| slots[i][:width] == 3 }
            if downgrade_index
              slots[downgrade_index][:width] = 2
              row_remaining += 1
              chosen = desired
            end
          end
        end
      end

      if chosen.nil?
        flexible_in_row.clear
        row_remaining = row_columns
        chosen = desired
      end

      row_remaining -= chosen
      slots << { width: chosen }
      flexible_in_row << (slots.length - 1) if adjustable
      chosen
    end

    # The "add new" card keeps whatever width it's assigned, but it must
    # never be the one silently downgraded later to make room for other
    # cards in its row — so it's excluded from flexible_in_row.
    if include_add_space && memories.empty?
      slots << { width: row_columns }
    elsif include_add_space
      assign_width.call(next_pattern_width.call, true, adjustable: false)
    end

    memories.each do |memory|
      desired = next_pattern_width.call
      desired = 2 unless memory.image.present?
      assign_width.call(desired, memory.image.present?)
    end

    {
      add_space_width: include_add_space ? slots.first[:width] : nil,
      memory_widths: slots.last(memories.size).map { |s| s[:width] }
    }
  end
end
