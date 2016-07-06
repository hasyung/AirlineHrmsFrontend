# 左侧菜单栏
nb = @nb
app = nb.app

menuFactory = ($rootScope, $state)->
    sections = []

    sections.push {
        name: '待办事项'
        type: 'link'
        state: 'TODO'
        icon_src: '/images/svg/left-side-svg/left_icon_22.svg'
    }

    sections.push {
        name: '组织机构'
        type: 'link'
        state: 'org'
        icon_src: '/images/svg/left-side-svg/left_icon_2.svg'
    }

    sections.push {
        name: '岗位管理'
        icon_src: '/images/svg/left-side-svg/left_icon_3.svg'
        pages: [
            {
                name: '岗位列表'
                state: 'position_list'
                permission: 'position_index'
            }
            {
                name: '岗位异动记录'
                state: 'position_changes'
                permission: 'position_change_index'
            }
        ]
    }

    sections.push {
        name: '人事信息'
        icon_src: '/images/svg/left-side-svg/left_icon_4.svg'
        pages: [
            {
                name: '人事花名册'
                state: 'personnel_list'
                permission: 'employees_index'
            }
            {
                name: '新员工列表'
                state: 'personnel_fresh'
                permission: ''
            }
            {
                name: '人事变更信息'
                state: 'personnel_review'
                permission: ''
            }
        ]
    }

    #sections.push {
    #    name: '培训管理'
    #    icon_src: '/images/svg/left-side-svg/left_icon_6.svg'
    #    pages: [
    #        {
    #            name: '培训记录'
    #            state: 'position'
    #            permission: ''
    #        }
    #        {
    #            name: '学历变更管理'
    #            state: 'position'
    #            permission: ''
    #        }
    #    ]
    #}

    sections.push {
        name: '劳动关系'
        icon_src: '/images/svg/left-side-svg/left_icon_9.svg'
        pages: [
            {
                name: '员工考勤'
                state: 'labors_attendance'
                permission: ''
            }
            {
                name: '员工调动'
                state: 'labors_ajust_position'
                permission: ''
            }
            {
                name: '员工退休'
                state: 'labors_retirement'
                permission: ''
            }
            {
                name: '员工退养'
                state: 'labors_early_retirement'
                permission: ''
            }
            {
                name: '员工辞退'
                state: 'labors_dismiss'
                permission: ''
            }
            #{
            #    name: '员工处分'
            #    state: 'labors_punishment'
            #    permission: ''
            #}
            {
                name: '合同管理'
                state: 'contract_management'
                permission: ''
            }
            {
                name: '协议管理'
                state: 'protocol_management'
                permission: ''
            }
            {
                name: '员工辞职'
                state: 'labors_resignation'
                permission: ''
            }
            {
                name: '员工离职'
                state: 'labors_leave_job'
                permission: ''
            }
            {
                name: '客舱管理'
                state: 'cabin_management'
                permission: ''
            }
        ]
    }

    sections.push {
        name: '薪酬管理'
        icon_src: '/images/svg/left-side-svg/left_icon_8.svg'
        pages: [
            {
                name: '薪酬设置'
                state: 'salary'
            }
            {
                name: '个人薪酬设置'
                state: 'salary_personal'
            }
            {
                name: '薪酬计算'
                state: 'salary_calc'
            }
        ]
    }

    sections.push {
        name: '福利管理'
        icon_src: '/images/svg/left-side-svg/left_icon_7.svg'
        pages: [
            {
                name: '福利设置'
                state: 'welfares'
                permission: ''
            }
            {
                name: '社保'
                state: 'welfares_socials'
                permission: ''
            }
            {
                name: '企业年金'
                state: 'welfares_annuities'
                permission: ''
            }
            {
                name: '工作餐'
                state: 'welfares_dinnerfee'
                permission: ''
            }
            {
                name: '生育津贴'
                state: 'welfares_birth'
                permission: ''
            }
        ]
    }

    sections.push {
        name: '绩效管理'
        icon_src: '/images/svg/left-side-svg/left_icon_10.svg'
        pages: [
            {
                name: '绩效记录'
                state: 'performance_list'
                permission: ''
            }
            {
                name: '绩效申诉'
                state: 'performance_alleges'
                permission: ''
            }
            {
                name: '绩效设置'
                state: 'performance_setting'
                permission: ''
            }
        ]
    }

    sections.push {
        name: '科室管理'
        icon_src: '/images/svg/left-side-svg/left_icon_8.svg'
        pages: [
            {
                name: '报表管理'
                state: 'department_chart'
            }
        ]
    }

    self = {
        sections: sections

        selectSection: (section) ->
            self.openedSection = section

        toggleSelectSection: (section) ->
            self.openedSection = if self.openedSection == section then null else section

        isSectionSelected: (section) ->
            return self.openedSection == section

        selectPage: (section, page) ->
            self.openedSection = section
            self.currentPage = page

        isPageSelected: (page) ->
            return @.currentPage == page
    }

    onLocationChange = () ->
        matchPage = (section, page) ->
            if page.state && $state.includes(page.state)
                self.selectPage(section, page)

        sections.forEach (section) ->
            if section.type == 'link'
                matchPage(section, section)
            else if section.pages
                section.pages.forEach (page) ->
                    matchPage(section, page)

    $rootScope.$on('$stateChangeSuccess', onLocationChange)

    return self


menuLinkDirective = ($compile, $state) ->
    origin_template = '''
        <md-button href="${ url }">
          <div flex layout="layout">
            <span>
                ${ stroke_template }
            </span>
            <span>{{ ::page.name }}</span>
            <span flex></span>
          </div>
        </md-button>
    '''

    menu_template = '''
        <md-button href="${ url }" class="md-button-toggle" flex>
            <div flex layout="row">
                <span>
                    <md-icon class="type-icon" md-svg-src="{{ page.icon_src }}"></md-icon>
                </span>
                <span> {{ ::page.name }}</span>
                <span flex></span>
            </div>
        <md-button>
    '''

    stroke_svg = '''
        <svg width="30" height="50">
            <path d="M1 0 L1 25 L21 25 M1 25 L1 50" fill="transparent" stroke="#cacaca" stroke-width="1"></path>
            <circle r="4" cx="21" cy="25" fill="#cacaca"></circle>
        </svg>
    '''

    last_stroke_svg = '''
        <svg width="30" height="40">
            <path d="M1 0 L1 25 L21 25" fill="transparent" stroke="#cacaca" stroke-width="1"></path>
            <circle r="4" cx="21" cy="25" fill="#cacaca"></circle>
        </svg>
    '''

    postLink = (scope, elem, attrs) ->
        page = scope.page

        compiled = _.template if angular.isDefined(attrs.menu) then menu_template else origin_template

        template = compiled {
            url: $state.href(page.state)
            stroke_template: if scope.isLast() then last_stroke_svg else stroke_svg
        }

        transcludeFn = $compile(template)
        transcludeFn scope, (cloned) ->
            elem.append(cloned)

    return {
        scope: {
            page: '='
            isLast: '&'
        }

        link: postLink
    }


menuToggleDirective = (menu) ->
    template = '''
      <md-button flex="flex" class="md-button-toggle" ng-click="toggle()">
        <div flex layout="row">
          <span>
            <md-icon class="type-icon" md-svg-src="{{ section.icon_src }}"></md-icon>
          </span>
          <span>{{ section.name }}</span>
          <span flex></span>
          <span ng-class="{'toggled': isOpen()}" class="md-toggle-icon">
            <md-icon md-svg-src="md-toggle-arrow"></md-icon>
          </span>
        </div>
      </md-button>

      <ul ng-show="isOpen()" class="menu-toggle-list">
        <li ng-class="{'active': isSelected(page)}" class="child-list-item" ng-repeat="page in ::section.pages track by $index">
            <menu-link is-last="$last" page="page"></menu-link>
        </li>
      </ul>
    '''

    postLink = (scope, elem) ->
        scope.toggle = () ->
            menu.toggleSelectSection(scope.section)

        scope.isOpen = () ->
            menu.isSectionSelected(scope.section)

        scope.isSelected = (page) ->
            menu.isPageSelected(page)

    return {
        template: template
        link: postLink
        scope: {
            section: '='
        }
    }


app.factory 'menu', menuFactory
app.directive 'menuLink', ['$compile', '$state', menuLinkDirective]
app.directive 'menuToggle', ['menu', menuToggleDirective]