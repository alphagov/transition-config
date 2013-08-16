class Reporter
  def blank_old_url(row)
  end

  def invalid_old_url(row)
    output [ ' ',
      row['old url'],
      'invalid old url',
      row['source'],
      row['row_number']
    ]
  end

  def invalid_new_url(row, new_url)
    output [ ' ',
      new_url,
      'invalid new url',
      row['source'],
      row['row_number']
    ]
  end

  def new_url_is_admin_url(url)
  end

  def circular_dependency(url, row)
    output [ ' ',
      url,
      'circular dependency',
      row['source'],
      row['row_number']
    ]
  end

  def output(fields)
    $stderr.puts fields.join(',')
  end
end

