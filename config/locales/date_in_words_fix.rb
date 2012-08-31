 I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
{
:en => {:'i18n' => {:plural => {:rule => lambda { |n| n == 1 ? :one : :other }}}},
:es => {:'i18n' => {:plural => {:rule => lambda { |n| n == 1 ? :one : :other }}}}
}
