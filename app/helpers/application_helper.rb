module ApplicationHelper
  def origin_breadcrumb
    path = referrer_path
    return [] if path.blank?

    case path
    when %r{\A/timeline\b}
      [ { label: "Лента времени", path: timeline_path } ]
    when %r{\A/family_tree\b}
      [ { label: "Семейное древо", path: family_tree_path } ]
    when %r{\A/profile/(\d+)\z}
      profile = Profile.find_by(id: $1)
      profile ? [ { label: profile.name.presence || "Без имени", path: profile_path(profile) } ] : []
    when %r{\A/profile\z}
      profile = current_user.profile
      [ { label: profile&.name.presence || "Профиль", path: my_profile_path } ]
    when %r{\A/collections/(\d+)\z}
      collection = Collection.find_by(id: $1)
      collection ? [ { label: collection.title.presence || "Подборка", path: collection_path(collection) } ] : []
    else
      []
    end
  end

  def truncate_clean(text, length:, omission: "...")
    text = text.to_s
    return text if text.length <= length

    "#{truncate(text, length: length, separator: " ", omission: "").rstrip}#{omission}"
  end

  private

  def referrer_path
    return nil if request.referrer.blank?

    URI.parse(request.referrer).path
  rescue URI::InvalidURIError
    nil
  end
end
