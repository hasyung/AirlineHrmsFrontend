
# 你


nb = @nb
app = nb.app


self_section = name: '员工自助'
org_section = name: '组织机构', type: 'link'
position_section = name: '岗位管理'
personnel_section = name: '人事信息'
kaoqin_section = name: '考勤管理'
train_section = name: '培训管理'
benefit_section = name: '福利'
salary_section = name: '薪酬'
labor_section = name: '劳动关系'
perf_section = name: '绩效管理'




menuFactory = ->
    sections = []

    sections.push {
        name: '员工自助'
        pages: [
            {
                name: '我的基本信息'
                state: 'self.profile'
            }
            {
                name: '优免票'
                state: 'self.profile'
            }
            {
                name: '学历变更申请'
                state: 'self.profile'
            }
            {
                name: '绩效申述'
                state: 'self.profile'
            }

            {
                name: '信息变更记录'
                state: 'self.profile'
            }
            {
                name: '公司通讯录'
                state: 'self.profile'
            }
            {
                name: '部门信箱'
                state: 'self.profile'
            }
        ]
    }


    sections.push {
        name: '组织机构'
        type: 'link'
        state: 'org'
    }


    sections.push {
        name: '岗位管理'
        pages: [
            {
                name: '岗位列表'
                state: 'position'
                permission: ''
            }
            {
                name: '岗位分布图'
                state: 'position'
                permission: ''
            }
            {
                name: '岗位异动记录'
                state: 'position'
                permission: ''
            }

        ]
    }


    sections.push {
        name: '人事信息'
        pages: [
            {
                name: '人事花名册'
                state: 'position'
                permission: ''
            }
            {
                name: '新员工列表'
                state: 'position'
                permission: ''
            }
            {
                name: '人事变更信息'
                state: 'position'
                permission: ''
            }

        ]
    }


    sections.push {
        name: '考勤管理'
        pages: [
            {
                name: '考勤记录'
                state: 'position'
                permission: ''
            }
            {
                name: '假别设置'
                state: 'position'
                permission: ''
            }
            {
                name: '请假管理'
                state: 'position'
                permission: ''
            }

        ]
    }


    sections.push {
        name: '培训管理'
        pages: [
            {
                name: '培训大纲'
                state: 'position'
                permission: ''
            }
            {
                name: '培训记录'
                state: 'position'
                permission: ''
            }
            {
                name: '教员管理'
                state: 'position'
                permission: ''
            }
            {
                name: '学历变更管理'
                state: 'position'
                permission: ''
            }

        ]
    }


    sections.push {
        name: '福利'
        pages: [
            {
                name: '公务餐'
                state: 'position'
                permission: ''
            }
            {
                name: '社保'
                state: 'position'
                permission: ''
            }
            {
                name: '企业年金'
                state: 'position'
                permission: ''
            }
            {
                name: '住房公积金'
                state: 'position'
                permission: ''
            }
            {
                name: '劳保制服'
                state: 'position'
                permission: ''
            }
        ]
    }

    sections.push {
        name: '薪酬'
        pages: [
            {
                name: '基础公司'
                state: 'position'
                permission: ''
            }
            {
                name: '飞行员小时费'
                state: 'position'
                permission: ''
            }
            {
                name: '空勤驻站补贴'
                state: 'position'
                permission: ''
            }
            {
                name: '交通费'
                state: 'position'
                permission: ''
            }
            {
                name: '实习费'
                state: 'position'
                permission: ''
            }
            {
                name: '事件奖励'
                state: 'position'
                permission: ''
            }
            {
                name: '津补贴'
                state: 'position'
                permission: ''
            }
            {
                name: '劳务费'
                state: 'position'
                permission: ''
            }
        ]
    }

    sections.push {
        name: '劳动关系'
        pages: [
            {
                name: '员工入职'
                state: 'position'
                permission: ''
            }
            {
                name: '员工转正'
                state: 'position'
                permission: ''
            }
            {
                name: '员工调动'
                state: 'position'
                permission: ''
            }
            {
                name: '员工退休'
                state: 'position'
                permission: ''
            }
            {
                name: '员工退养'
                state: 'position'
                permission: ''
            }
            {
                name: '员工辞退'
                state: 'position'
                permission: ''
            }
            {
                name: '合同管理'
                state: 'position'
                permission: ''
            }
            {
                name: '档案管理'
                state: 'position'
                permission: ''
            }

        ]
    }

    sections.push {
        name: '绩效管理'
        pages: [
            {
                name: '绩效设置'
                state: 'position'
                permission: ''
            }
            {
                name: '绩效记录'
                state: 'position'
                permission: ''
            }
            {
                name: '绩效申诉管理'
                state: 'position'
                permission: ''
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
    }

    return self




menuLinkDirective = ($compile, $state) ->

    origin_template = '''
        <md-button href="${ url }" ng-class="{'active': isSelected()}">
          <div flex layout="layout">
            <span>
                ${ stroke_template }
            </span>
            <span>{{ page.name }}</span>
            <span flex></span>
          </div>
        </md-button>
    '''

    stroke_svg = '''
        <svg width="30" height="50">
            <path d="M1 0 L1 25 L21 25 M1 25 L1 50" fill="transparent" stroke="#aaa" stroke-width="1"></path>
            <circle r="4" cx="21" cy="25" fill="#aaa"></circle>
        </svg>
    '''

    last_stroke_svg = '''
        <svg width="30" height="40">
            <path d="M1 0 L1 25 L21 25" fill="transparent" stroke="#aaa" stroke-width="1"></path>
            <circle r="4" cx="21" cy="25" fill="#aaa"></circle>
        </svg>
    '''

    postLink = (scope, elem) ->
        page = scope.page

        compiled = _.template(origin_template)

        template = compiled {
            url: $state.href(page.state)
            stroke_template: if scope.isLast() then last_stroke_svg else stroke_svg
        }

        transcludeFn = $compile(template)
        transcludeFn scope, (cloned) -> elem.append(cloned)

        scope.isSelected = ->
            $state.is(scope.page)

    return {
        # template: template
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
            <md-icon md-svg-src="/images/svg/ic_star_24px.svg"></md-icon>
          </span>
          <span>{{ section.name }}</span>
          <span flex></span>
          <span ng-class="{'toggled': isOpen()}" class="md-toggle-icon">
            <md-icon md-svg-src="md-toggle-arrow"></md-icon>
          </span>
        </div>
      </md-button>
      <ul ng-show="isOpen()" class="menu-toggle-list">
        <li class="child-list-item" ng-repeat="page in section.pages">
            <menu-link is-last="$last" page="page"></menu-link>
        </li>
      </ul>
    '''

    postLink = (scope, elem) ->

        scope.toggle = () ->
            menu.toggleSelectSection(scope.section)

        scope.isOpen = () ->
            menu.isSectionSelected(scope.section)


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

